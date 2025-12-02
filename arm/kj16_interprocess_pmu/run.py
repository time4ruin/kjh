#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import subprocess
import sys
import time
import threading
from pathlib import Path
from typing import Tuple, Optional


# ======================= 설정 =======================

# WSL에서 사용하는 adb 래퍼 명령
ADB_CMD = "/mnt/c/Users/time4/platform-tools/adb.exe"

# 디바이스 쪽 디렉터리
REMOTE_DIR = "/data/local/tmp"

# 파일 이름들
ATTACKER_BIN = "attacker.bin"
VICTIM_BIN   = "victim.bin"
ATTACKER_SRC = Path("attacker.c")

# NOP 조정 관련
MAX_NOP_PER_BLOCK = 8000   # NOP_REPEAT 한 번에 최대
PADFINE_MAX        = 10    # PADFINE1 / PADFINE2는 최대 10개 NOP

# 정렬 알고리즘 파라미터
ALIGN_MAX_ITER     = 30
CPU_MASK           = "1"   # taskset 마스크 (예: "1" → CPU0)

# 최초 주소 읽을 때 기다릴 최대 시간(초)
ADDR_READ_TIMEOUT  = 5.0


# ======================= adb helper =======================

def adb(*args,
        capture_output: bool = True,
        check: bool = True,
        text: bool = True,
        **kwargs) -> subprocess.CompletedProcess:
    cmd = [ADB_CMD, *args]
    # print("[ADB]", " ".join(cmd))
    return subprocess.run(
        cmd,
        capture_output=capture_output,
        check=check,
        text=text,
        **kwargs,
    )


def push_bin(bin_name: str) -> None:
    local = Path(bin_name)
    if not local.exists():
        raise FileNotFoundError(f"{bin_name} not found in current directory")
    remote = f"{REMOTE_DIR}/{bin_name}"
    print(f"[+] push {bin_name} → {remote}")
    adb("push", str(local), remote, capture_output=False)


def chmod_x(bin_name: str) -> None:
    adb(
        "shell",
        f"cd {REMOTE_DIR} && chmod +x ./{bin_name}",
        capture_output=False,
    )


def kill_remote_by_name(bin_name: str) -> None:
    """
    디바이스에서 해당 바이너리 이름을 가진 프로세스를 죽인다.
    (없으면 에러 무시)
    """
    try:
        adb("shell", f"pkill {bin_name}", capture_output=False)
    except subprocess.CalledProcessError:
        pass


# ======================= attacker.c NOP 블록 수정 =======================

def _emit_nops(n_value: int) -> str:
    """
    NOP_REPEAT(n)를 여러 개로 쪼개서 생성 (C 구문)
    """
    n_value = max(0, int(n_value))
    if n_value <= 0:
        return "\n    "

    blocks = []
    remaining = n_value
    while remaining > 0:
        chunk = min(remaining, MAX_NOP_PER_BLOCK)
        blocks.append(f"NOP_REPEAT({chunk});")
        remaining -= chunk

    return "\n    " + "\n    ".join(blocks) + "\n"


def _replace_region(region_name: str,
                    n_value: int,
                    max_nops_total: Optional[int] = None) -> None:
    """
    attacker.c 안에서
        /* REGION_NAME start */ ... /* REGION_NAME end */
    구간을 찾아 NOP_REPEAT(...) 블록으로 교체.

    region_name 예시:
      - "PAD1"
      - "PADFINE1"
      - "PAD2"
      - "PADFINE2"
    """
    if max_nops_total is not None:
        n_value = min(max(0, n_value), max_nops_total)
    else:
        n_value = max(0, n_value)

    src = ATTACKER_SRC.read_text()

    # 주석 그대로 사용 (공백은 느슨하게 매칭)
    pattern = re.compile(
        rf'(/\*\s*{region_name}\s*start\s*\*/)(.*?)(/\*\s*{region_name}\s*end\s*\*/)',
        flags=re.DOTALL,
    )
    m = pattern.search(src)
    if not m:
        raise RuntimeError(
            f"Cannot find '/* {region_name} start */ ... /* {region_name} end */' in {ATTACKER_SRC}"
        )

    prefix, old_body, suffix = m.group(1), m.group(2), m.group(3)
    new_body = _emit_nops(n_value)

    new_src = src[:m.start()] + prefix + new_body + suffix + src[m.end():]
    ATTACKER_SRC.write_text(new_src)


def set_attacker_pads(pad1: int,
                      padfine1: int,
                      pad2: int,
                      padfine2: int) -> None:
    """
    attacker.c 의 PAD1 / PADFINE1 / PAD2 / PADFINE2 NOP 개수 설정
    """
    print(f"[i] set pads: PAD1={pad1}, PADFINE1={padfine1}, PAD2={pad2}, PADFINE2={padfine2}")
    _replace_region("PAD1", pad1)
    _replace_region("PADFINE1", padfine1, max_nops_total=PADFINE_MAX)
    _replace_region("PAD2", pad2)
    _replace_region("PADFINE2", padfine2, max_nops_total=PADFINE_MAX)


# ======================= 빌드 =======================

def build_binaries(targets=("attacker.bin", "victim.bin")) -> None:
    """
    Makefile에서 attacker.bin / victim.bin 타겟이 정의되어 있다고 가정.
    """
    print("[+] make", " ".join(targets))
    subprocess.run(
        ["make", *targets],
        check=True,
    )


# ======================= 주소 파싱 / 실행 =======================

# victim/attacker의 printf 포맷에 맞춘 정규식
# [VIC] address of outer branch: 0x...
# [ATK] address of outer branch: 0x...
RE_VIC_OUTER = re.compile(r'\[VIC\]\s*address of outer branch:\s*(0x[0-9a-fA-F]+)')
RE_VIC_INNER = re.compile(r'\[VIC\]\s*address of inner branch:\s*(0x[0-9a-fA-F]+)')
RE_ATK_OUTER = re.compile(r'\[ATK\]\s*address of outer branch:\s*(0x[0-9a-fA-F]+)')
RE_ATK_INNER = re.compile(r'\[ATK\]\s*address of inner branch:\s*(0x[0-9a-fA-F]+)')


def _parse_addr(regex, text: str) -> Optional[int]:
    m = regex.search(text)
    if not m:
        return None
    return int(m.group(1), 16)


def run_on_device_and_grab_addrs(bin_name: str,
                                 who: str) -> Tuple[Optional[int], Optional[int], str]:
    """
    디바이스에서 {bin_name}을 taskset으로 실행하고,
    stdout을 읽다가 outer/inner branch 주소를 파싱.
    - who: "VIC" or "ATK"
    - 주소 두 개 다 얻으면 즉시 pkill로 죽이고 stdout 반환
    """
    cmd = [
        ADB_CMD,
        "shell",
        f"cd {REMOTE_DIR} && taskset {CPU_MASK} ./{bin_name}",
    ]
    print("[+] run:", " ".join(cmd))

    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    collected = []
    b_outer = None
    b_inner = None
    start = time.time()

    try:
        while True:
            if time.time() - start > ADDR_READ_TIMEOUT:
                print(f"[!] timeout while waiting for addresses from {bin_name}")
                break

            line = proc.stdout.readline()
            if not line:
                break

            collected.append(line)

            out_text = "".join(collected)

            if who == "VIC":
                b_outer = _parse_addr(RE_VIC_OUTER, out_text) or b_outer
                b_inner = _parse_addr(RE_VIC_INNER, out_text) or b_inner
            elif who == "ATK":
                b_outer = _parse_addr(RE_ATK_OUTER, out_text) or b_outer
                b_inner = _parse_addr(RE_ATK_INNER, out_text) or b_inner
            else:
                raise ValueError("who must be 'VIC' or 'ATK'")

            if b_outer is not None and b_inner is not None:
                print(f"[i] {bin_name}: outer=0x{b_outer:x}, inner=0x{b_inner:x}")
                break
    finally:
        # 주소를 받았든 못 받았든 프로세스 종료 시도
        kill_remote_by_name(bin_name)
        try:
            proc.kill()
        except Exception:
            pass
        try:
            proc.wait(timeout=1)
        except Exception:
            pass

    return b_outer, b_inner, "".join(collected)


# ======================= 정렬 로직 =======================

def align_outer(target_outer: int,
                pad1_init: int,
                padfine1_init: int,
                pad2: int,
                padfine2: int) -> Tuple[int, int]:
    """
    PAD1 / PADFINE1을 조정해서 attacker의 outer(branch1) 주소를 victim과 맞춘다.
    PAD2/PADFINE2는 고정.
    (NOP은 추가만 된다고 가정 → 현재 주소가 target보다 크면 불가능)
    """
    pad1 = max(0, pad1_init)
    padfine1 = max(0, padfine1_init)

    print(f"[==] Align outer branch to 0x{target_outer:x} (start PAD1={pad1}, PADFINE1={padfine1})")

    last_outer = None

    for _ in range(ALIGN_MAX_ITER):
        set_attacker_pads(pad1, padfine1, pad2, padfine2)
        build_binaries(targets=(ATTACKER_BIN,))
        push_bin(ATTACKER_BIN)
        chmod_x(ATTACKER_BIN)

        outer_addr, inner_addr, _ = run_on_device_and_grab_addrs(ATTACKER_BIN, who="ATK")
        last_outer = outer_addr

        if outer_addr is None:
            print("[!] failed to read outer branch address from attacker", file=sys.stderr)
            break

        print(f"[i] attacker outer=0x{outer_addr:x}")

        if outer_addr == target_outer:
            print(f"[✓] outer aligned: 0x{outer_addr:x}, PAD1={pad1}, PADFINE1={padfine1}")
            return pad1, padfine1

        if outer_addr > target_outer:
            print(
                f"[x] current outer=0x{outer_addr:x} > target=0x{target_outer:x}; "
                "NOP을 추가만 하는 모델에서는 이론적으로 불가능",
                file=sys.stderr,
            )
            break

        delta_bytes = target_outer - outer_addr
        add_nops = (delta_bytes + 3) // 4      # 대략 필요 NOP 수 (4바이트 정렬)

        room_fine = PADFINE_MAX - padfine1
        use_fine = min(add_nops, max(0, room_fine))

        padfine1 += use_fine
        pad1     += (add_nops - use_fine)

        print(
            f"[i] adjust outer: delta_bytes={delta_bytes}, add_nops={add_nops} "
            f"→ PAD1={pad1}, PADFINE1={padfine1}"
        )

    print(
        f"[!] outer alignment failed; last outer="
        f"{'None' if last_outer is None else hex(last_outer)}",
        file=sys.stderr,
    )
    return pad1, padfine1


def align_inner(target_inner: int,
                target_outer: int,
                pad1: int,
                padfine1: int,
                pad2_init: int,
                padfine2_init: int) -> Tuple[int, int, bool]:
    """
    PAD2 / PADFINE2를 조정해서 attacker의 inner(branch2) 주소를 victim과 맞춘다.
    이때 outer(branch1)는 이미 target_outer로 맞춰져 있어야 하고,
    PAD1 / PADFINE1은 고정.

    - inner > target_inner이면 (NOP 추가만으로) 불가능
    - PAD2/PADFINE2 조정 중에 outer가 움직이면 구조상 맞추기 불가능 → 실패 처리
    """
    pad2 = max(0, pad2_init)
    padfine2 = max(0, padfine2_init)

    print(f"[==] Align inner branch to 0x{target_inner:x} (start PAD2={pad2}, PADFINE2={padfine2})")

    last_outer = None
    last_inner = None

    for _ in range(ALIGN_MAX_ITER):
        set_attacker_pads(pad1, padfine1, pad2, padfine2)
        build_binaries(targets=(ATTACKER_BIN,))
        push_bin(ATTACKER_BIN)
        chmod_x(ATTACKER_BIN)

        outer_addr, inner_addr, _ = run_on_device_and_grab_addrs(ATTACKER_BIN, who="ATK")
        last_outer, last_inner = outer_addr, inner_addr

        if outer_addr is None or inner_addr is None:
            print("[!] failed to read addresses from attacker", file=sys.stderr)
            break

        print(f"[i] attacker outer=0x{outer_addr:x}, inner=0x{inner_addr:x}")

        # PAD2/PADFINE2는 dummy2()/inner() 쪽이어서 outer가 움직이면 말이 안 됨
        if outer_addr != target_outer:
            print(
                f"[x] outer moved while adjusting PAD2/PADFINE2: "
                f"outer=0x{outer_addr:x}, expected=0x{target_outer:x}",
                file=sys.stderr,
            )
            return pad2, padfine2, False

        if inner_addr == target_inner:
            print(f"[✓] inner aligned: 0x{inner_addr:x}, PAD2={pad2}, PADFINE2={padfine2}")
            return pad2, padfine2, True

        if inner_addr > target_inner:
            print(
                f"[x] current inner=0x{inner_addr:x} > target=0x{target_inner:x}; "
                "NOP 추가만으로는 불가능",
                file=sys.stderr,
            )
            break

        delta_bytes = target_inner - inner_addr
        add_nops = (delta_bytes + 3) // 4

        room_fine = PADFINE_MAX - padfine2
        use_fine  = min(add_nops, max(0, room_fine))

        padfine2 += use_fine
        pad2     += (add_nops - use_fine)

        print(
            f"[i] adjust inner: delta_bytes={delta_bytes}, add_nops={add_nops} "
            f"→ PAD2={pad2}, PADFINE2={padfine2}"
        )

    print(
        f"[!] inner alignment failed; last outer="
        f"{'None' if last_outer is None else hex(last_outer)}, "
        f"last inner={'None' if last_inner is None else hex(last_inner)}",
        file=sys.stderr,
    )
    return pad2, padfine2, False


# ======================= 병렬 실행 + 결과 pull (옵션) =======================

def stream_output(tag: str, proc: subprocess.Popen, logfile: Optional[str] = None):
    f = open(logfile, "w", encoding="utf-8") if logfile else None
    try:
        for line in proc.stdout:
            line = line.rstrip("\n")
            print(f"[{tag}] {line}")
            if f:
                f.write(line + "\n")
                f.flush()
    finally:
        if f:
            f.close()


def run_attacker_victim_parallel():
    """
    attacker.bin / victim.bin을 같은 코어에서 동시에 실행하고
    stdout을 각각 따로 로그 파일에 저장.
    실행이 끝나면 p1.txt / p2.txt를 pull.
    """
    print("[+] run attacker/victim in parallel")

    # attacker
    atk_cmd = [
        ADB_CMD,
        "shell",
        f"cd {REMOTE_DIR} && taskset {CPU_MASK} ./attacker.bin",
    ]
    vic_cmd = [
        ADB_CMD,
        "shell",
        f"cd {REMOTE_DIR} && taskset {CPU_MASK} ./victim.bin",
    ]

    atk_proc = subprocess.Popen(
        atk_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )
    vic_proc = subprocess.Popen(
        vic_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    t1 = threading.Thread(
        target=stream_output,
        args=("ATK", atk_proc),
        kwargs={"logfile": "attacker_stdout.txt"},
        daemon=True,
    )
    t2 = threading.Thread(
        target=stream_output,
        args=("VIC", vic_proc),
        kwargs={"logfile": "victim_stdout.txt"},
        daemon=True,
    )
    t1.start()
    t2.start()

    atk_rc = atk_proc.wait()
    vic_rc = vic_proc.wait()
    t1.join()
    t2.join()

    print(f"[i] attacker exit code = {atk_rc}")
    print(f"[i] victim   exit code = {vic_rc}")

    # 결과 파일 pull
    for fname in ("p1.txt", "p2.txt"):
        remote = f"{REMOTE_DIR}/{fname}"
        local  = fname
        try:
            print(f"[+] pull {remote} → {local}")
            adb("pull", remote, local, capture_output=False)
        except subprocess.CalledProcessError:
            print(f"[WARN] failed to pull {remote}")


# ======================= 메인 =======================

def main():
    # 0) victim 빌드/배포 + 주소 측정
    print("[==] build & push victim")
    build_binaries(targets=(VICTIM_BIN,))
    push_bin(VICTIM_BIN)
    chmod_x(VICTIM_BIN)

    v_outer, v_inner, _ = run_on_device_and_grab_addrs(VICTIM_BIN, who="VIC")
    if v_outer is None or v_inner is None:
        print("[FATAL] cannot read victim outer/inner branch addresses", file=sys.stderr)
        sys.exit(1)

    print()
    print("========================================")
    print("          VICTIM BRANCH ADDRESSES        ")
    print("----------------------------------------")
    print(f"  outer : {hex(v_outer)}")
    print(f"  inner : {hex(v_inner)}")
    print("========================================")
    print()

    # 1) 초기 패드 값 (지금 attacker.c에 들어있는 값과 맞춰도 되고, 0으로 시작해도 됨)
    pad1_init     = 149     # 현재 dummy1 NOP_REPEAT(149)
    padfine1_init = 0       # 현재 outer PADFINE1 NOP_REPEAT(9)
    pad2_init     = 11000   # 현재 dummy2 NOP_REPEAT(110)
    padfine2_init = 0       # 현재 inner PADFINE2 NOP_REPEAT(9)

    # 2) outer 정렬
    pad1, padfine1 = align_outer(
        target_outer=v_outer,
        pad1_init=pad1_init,
        padfine1_init=padfine1_init,
        pad2=pad2_init,
        padfine2=padfine2_init,
    )

    # outer가 진짜로 맞았는지 한 번 더 체크
    set_attacker_pads(pad1, padfine1, pad2_init, padfine2_init)
    build_binaries(targets=(ATTACKER_BIN,))
    push_bin(ATTACKER_BIN)
    chmod_x(ATTACKER_BIN)
    a_outer, a_inner, _ = run_on_device_and_grab_addrs(ATTACKER_BIN, who="ATK")
    if a_outer != v_outer:
        print(
            f"[FATAL] after outer align, attacker outer=0x{0 if a_outer is None else a_outer:x} "
            f"!= victim outer=0x{v_outer:x}",
            file=sys.stderr,
        )
        print("[FATAL] PAD1 / PADFINE1만으로는 victim outer와 동일 주소를 만들 수 없는 구조일 수 있습니다.")
        sys.exit(1)

    # 3) inner 정렬
    pad2, padfine2, ok = align_inner(
        target_inner=v_inner,
        target_outer=v_outer,
        pad1=pad1,
        padfine1=padfine1,
        pad2_init=pad2_init,
        padfine2_init=padfine2_init,
    )

    if not ok:
        print(
            "[FATAL] victim의 outer/inner 주소 간 간격을 "
            "attacker의 PAD1/PADFINE1/PAD2/PADFINE2로 구현하는 것이 "
            "이론적으로 불가능한 구조처럼 보입니다.",
            file=sys.stderr,
        )
        sys.exit(1)

    # 4) 최종 검증
    set_attacker_pads(pad1, padfine1, pad2, padfine2)
    build_binaries(targets=(ATTACKER_BIN,))
    push_bin(ATTACKER_BIN)
    chmod_x(ATTACKER_BIN)
    final_outer, final_inner, _ = run_on_device_and_grab_addrs(ATTACKER_BIN, who="ATK")

    print("\n[=== FINAL ALIGN RESULT ===]")
    print(f"victim : outer=0x{v_outer:x}, inner=0x{v_inner:x}")
    print(f"attacker: outer=0x{final_outer:x}, inner=0x{final_inner:x}")
    print(f"PAD1={pad1}, PADFINE1={padfine1}, PAD2={pad2}, PADFINE2={padfine2}")

    if final_outer != v_outer or final_inner != v_inner:
        print("[!] 최종 주소가 victim과 완전히 일치하진 않습니다.", file=sys.stderr)

    # 5) 필요하면 여기서 바로 병렬 실행까지
    run_attacker_victim_parallel()


if __name__ == "__main__":
    main()
