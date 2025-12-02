#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import subprocess
import sys
import time
from pathlib import Path
from typing import Optional, Tuple, List

# ------------ CONFIG ------------
BRANCHES_FILE = Path("branches.c")
MAX_NOP_PER_BLOCK = 8000  # .rept 제한

ADB_PATH = "/mnt/c/Users/time4/platform-tools/adb.exe"  # 윈도우 adb 경로 (WSL)
BUILD_CMD = ["make"]
PUSH_TARGET = "/data/local/tmp"
BIN_NAME = "test.bin"
CPUNUM = "1"

# dummy1의 초기 PAD 상태 (예: NOP_REPEAT(39); 로 시작했다고 가정)
PAD_INIT = 39
PADFINE1_INIT = 0
PADFINE1_MAX = 10

# adb 재시도 횟수
MAX_ADB_RETRY = 3

# 반복 실행 설정
LOOP_FOREVER = True      # True면 무한 반복, False면 NUM_ITER 번만
NUM_ITER = 3              # LOOP_FOREVER=False일 때 반복 횟수

# 결과 로그 파일
LOG_FILE = "run_specific_results.txt"

# 여기다가 원하는 (b1, b2) 쌍들을 넣어준다.
TARGET_PAIRS: List[Tuple[int, int]] = [
    (0x0000000000402258, 0x0000000000405258),
    (0x0000000000402258, 0x000000000040525c),
    (0x0000000000402258, 0x0000000000405a78),
    (0x0000000000402258, 0x0000000000405a7c),
    (0x0000000000402258, 0x0000000000405a80),
    (0x0000000000402258, 0x0000000000405a84),
    (0x0000000000402258, 0x0000000000405a90),
    (0x0000000000402258, 0x0000000000405a94),
    (0x0000000000402258, 0x0000000000405ab0),
    (0x0000000000402258, 0x0000000000405ab4),
    (0x0000000000402258, 0x0000000000406258),
    (0x0000000000402258, 0x000000000040625c),
    (0x0000000000402258, 0x0000000000406530),
    (0x0000000000402258, 0x000000000040657c),
    (0x0000000000402258, 0x000000000040659c),
    (0x0000000000402258, 0x0000000000406d30),
    (0x0000000000402258, 0x0000000000406dcc),

    (0x0000000000402258, 0x0000000000402d04),
    (0x0000000000402258, 0x0000000000402d30),
    (0x0000000000402258, 0x0000000000402d34),
    (0x0000000000402258, 0x000000000040325c),
    (0x0000000000402258, 0x00000000004034cc),
    (0x0000000000402258, 0x0000000000403530),
    (0x0000000000402258, 0x0000000000403534),
    (0x0000000000402258, 0x0000000000403d04),
    (0x0000000000402258, 0x0000000000403dcc),
    (0x0000000000402258, 0x0000000000403fa8),
    (0x0000000000402258, 0x0000000000403fb0),
    (0x0000000000402258, 0x0000000000403fc8),
    (0x0000000000402258, 0x0000000000403fd0),
    (0x0000000000402258, 0x0000000000403fe4),
    (0x0000000000402258, 0x0000000000403fe8),
    (0x0000000000402258, 0x0000000000403fec),
    (0x0000000000402258, 0x0000000000404000),
    (0x0000000000402258, 0x0000000000404004),
    (0x0000000000402258, 0x000000000040400c),
    (0x0000000000402258, 0x0000000000404010),
    (0x0000000000402258, 0x0000000000404014),
    (0x0000000000402258, 0x0000000000404018),
    (0x0000000000402258, 0x000000000040401c),
    (0x0000000000402258, 0x0000000000404020),
    (0x0000000000402258, 0x000000000040402c),
    (0x0000000000402258, 0x0000000000404030),
    (0x0000000000402258, 0x0000000000404034),
    (0x0000000000402258, 0x0000000000404038),
    (0x0000000000402258, 0x000000000040403c),
    (0x0000000000402258, 0x0000000000404040),
    (0x0000000000402258, 0x0000000000404530),
    (0x0000000000402258, 0x0000000000404534),
    (0x0000000000402258, 0x000000000040459c),
    (0x0000000000402258, 0x00000000004045c8),
    (0x0000000000402258, 0x00000000004045cc),
    (0x0000000000402258, 0x0000000000404dcc),
]

# --------------------------------


# ---------- file editing ----------
def _emit_nops(n_value: int) -> str:
    """NOP_REPEAT 블록 문자열 생성 (n_value가 0이면 그냥 빈 영역)."""
    n_value = max(0, int(n_value))
    if n_value <= 0:
        return "\n\t"

    blocks = []
    remaining = n_value
    while remaining > 0:
        chunk = min(remaining, MAX_NOP_PER_BLOCK)
        blocks.append(f"NOP_REPEAT({chunk});")
        remaining -= chunk
    return "\n\t" + "\n\t".join(blocks) + "\n\t"


def _replace_region(
    region_name: str,
    n_value: int,
    max_nops_total: Optional[int] = None,
    file_path: Path = BRANCHES_FILE,
) -> None:
    """
    region_name:
      - "PAD"              → dummy1:  /* PAD start */ ~ /* PAD end */
      - "PADFINE1_ENTRY"   → branch1: /* PADFINE1_ENTRY start */ ~ /* PADFINE1_ENTRY end */
      - "NOP"              → dummy2:  /* NOP start */ ~ /* NOP end */
    """
    if max_nops_total is not None:
        n_value = min(max(0, n_value), max_nops_total)

    content = file_path.read_text()

    pattern = re.compile(
        rf'(/\*\s*{region_name}\s*start\s*\*/)(.*?)(/\*\s*{region_name}\s*end\s*\*/)',
        flags=re.DOTALL,
    )
    m = pattern.search(content)
    if not m:
        raise RuntimeError(
            f"Could not find '/* {region_name} start */ ... /* {region_name} end */' region in {file_path}"
        )

    prefix, old_body, suffix = m.group(1), m.group(2), m.group(3)
    new_region = _emit_nops(n_value)

    new_content = content[:m.start()] + prefix + new_region + suffix + content[m.end():]
    file_path.write_text(new_content)


def set_pad(pad_nops: int) -> None:
    """dummy1의 PAD 영역 NOP 개수 세팅."""
    _replace_region("PAD", pad_nops)


def set_padfine1(padfine_nops: int) -> None:
    """branch1 앞 PADFINE1_ENTRY 영역 NOP 개수 세팅 (≤ PADFINE1_MAX)."""
    _replace_region("PADFINE1_ENTRY", padfine_nops, max_nops_total=PADFINE1_MAX)


def set_dummy2_nops(n_value: int) -> None:
    """dummy2 안의 /* NOP start */ ~ /* NOP end */ NOP 개수 세팅."""
    if n_value < 0:
        raise ValueError("dummy2_nops cannot be negative")
    _replace_region("NOP", n_value)


# ---------- adb & build ----------
def adbwin(*args,
           capture_output=True,
           check=True,
           text=True,
           retries: int = MAX_ADB_RETRY) -> subprocess.CompletedProcess:
    """
    adb wrapper with retry.
    - CalledProcessError 발생 시 최대 retries번까지 재시도.
    """
    cmd = [ADB_PATH, *args]
    last_err = None

    for attempt in range(1, retries + 1):
        try:
            return subprocess.run(
                cmd,
                capture_output=capture_output,
                check=check,
                text=text,
            )
        except subprocess.CalledProcessError as e:
            last_err = e
            print(
                f"[!] adb command failed (attempt {attempt}/{retries}): {cmd}",
                file=sys.stderr,
            )
            if attempt < retries:
                time.sleep(1.0)
            else:
                print("[X] adb command failed after all retries.", file=sys.stderr)
                raise last_err


def build_binary() -> None:
    subprocess.run(
        BUILD_CMD,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def push_and_run_on_device() -> str:
    adbwin("push", BIN_NAME, PUSH_TARGET)
    shell_cmd = f"cd {PUSH_TARGET} && chmod +x ./{BIN_NAME} && taskset {CPUNUM} ./{BIN_NAME}"
    cp = adbwin("shell", shell_cmd)
    return cp.stdout


# ---------- parsing ----------
def parse_addr(x):
    if isinstance(x, int):
        return x
    s = str(x).strip().lower()
    if s.startswith("0x"):
        return int(s, 16)
    if s.startswith("0b"):
        return int(s, 2)
    if all(c in "0123456789abcdef" for c in s):
        return int(s, 16)
    raise ValueError(f"Cannot parse address: {x}")


def parse_output(
    output_text: str,
) -> Tuple[Optional[str], Optional[str], Optional[float], Optional[float], Optional[float]]:
    """
    출력 포맷 예시:

    address of branch1: 0x402258
    address of branch2: 0x402648
    address of function2: 0x402544
    average (0000-0): 1.03        -> hit
    average (0001-0): 2.00        -> conj
    average (0000-b2-0): 1.55     -> miss
    """
    addr1 = None
    addr2 = None
    avg_hit = None
    avg_conj = None
    avg_miss = None

    m1 = re.search(r'address\s+of\s+branch1\s*:\s*(0x[0-9a-fA-F]+)', output_text)
    m2 = re.search(r'address\s+of\s+branch2\s*:\s*(0x[0-9a-fA-F]+)', output_text)
    if m1:
        addr1 = m1.group(1)
    if m2:
        addr2 = m2.group(1)

    mhit = re.search(r'average\s*\(\s*0000-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', output_text)
    mconj = re.search(r'average\s*\(\s*0001-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', output_text)
    mmiss = re.search(r'average\s*\(\s*0000-b2-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', output_text)

    if mhit:
        avg_hit = float(mhit.group(1))
    if mconj:
        avg_conj = float(mconj.group(1))
    if mmiss:
        avg_miss = float(mmiss.group(1))

    return addr1, addr2, avg_hit, avg_conj, avg_miss


# ---------- logging ----------
def log_result_to_file(b1_hex: str, b2_hex: str, da_int: int,
                       hit: Optional[float],
                       conj: Optional[float],
                       miss: Optional[float]) -> None:
    with open(LOG_FILE, "a") as f:
        f.write(
            f"b1={b1_hex}  b2={b2_hex}  da={hex(da_int)}  "
            f"hit={hit}  conj={conj}  miss={miss}\n"
        )


# ---------- single run ----------
def run_once(pad: int, padfine: int, dummy2_nops: int):
    """현재 PAD/PADFINE1/DUMMY2 상태로 빌드 + 실행해 결과를 반환."""
    set_pad(pad)
    set_padfine1(padfine)
    set_dummy2_nops(dummy2_nops)

    try:
        build_binary()
    except subprocess.CalledProcessError as e:
        print("[!] Build failed:", e, file=sys.stderr)
        raise

    try:
        out = push_and_run_on_device()
    except subprocess.CalledProcessError as e:
        print("[!] adb command failed:", e, file=sys.stderr)
        raise

    b1, b2, avg_hit, avg_conj, avg_miss = parse_output(out)
    return b1, b2, avg_hit, avg_conj, avg_miss


# ---------- branch1 alignment ----------
def align_branch1(b1_target: int,
                  pad_init: int,
                  padfine_init: int,
                  max_iter: int = 30) -> Tuple[int, int, Optional[int]]:
    """
    dummy1의 PAD와 branch1의 PADFINE1_ENTRY를 조절해서
    branch1 주소를 b1_target 으로 맞춘다.

    - PADFINE1은 최대 PADFINE1_MAX까지만 사용
    - nop 1개 = 4바이트
    - overshoot(현재 b1 > b1_target)이 되면 실패
    """
    pad = max(0, int(pad_init))
    padfine = max(0, int(padfine_init))

    print(f"\n[i] Align branch1 to 0x{b1_target:x} (start PAD={pad}, PADFINE1={padfine})")

    last_b1_int: Optional[int] = None

    for _ in range(max_iter):
        b1_hex, _, _, _, _ = run_once(pad, padfine, dummy2_nops=0)
        if not b1_hex:
            print("[!] align: failed to get branch1 address.", file=sys.stderr)
            return pad, padfine, None

        cur = int(b1_hex, 16)
        last_b1_int = cur
        print(f"[i] current b1 = {b1_hex}, PAD={pad}, PADFINE1={padfine}")

        if cur == b1_target:
            print(f"[✓] branch1 aligned to {b1_hex}")
            return pad, padfine, cur

        if cur > b1_target:
            print(
                f"[!] align: current b1=0x{cur:x} > target=0x{b1_target:x}, "
                f"cannot adjust further by adding NOPs only.",
                file=sys.stderr,
            )
            return pad, padfine, cur

        delta_bytes = b1_target - cur
        add_nops = (delta_bytes + 3) // 4  # 4byte 단위 올림

        # 먼저 PADFINE1 여유분 사용
        room_fine = PADFINE1_MAX - padfine
        use_fine = min(add_nops, max(0, room_fine))
        padfine += use_fine
        pad += (add_nops - use_fine)

        print(
            f"[i] align step: delta_bytes={delta_bytes}, add_nops={add_nops} "
            f"→ PAD={pad}, PADFINE1={padfine}"
        )

    print(
        f"[x] align: failed to converge to target 0x{b1_target:x}, last b1=0x{last_b1_int:x}"
        if last_b1_int is not None
        else "[x] align: failed with unknown b1",
        file=sys.stderr,
    )
    return pad, padfine, last_b1_int


# ---------- 원하는 (b1, b2) 쌍에 맞추기 ----------
def run_for_target_pair(b1_target: int,
                        b2_target: int,
                        pad_init: int,
                        padfine_init: int):
    """
    1) branch1을 b1_target으로 정렬
    2) dummy2_nops=0에서의 기준 거리 dist0 = b2_0 - b1
    3) target_dist = b2_target - b1_target
    4) delta = target_dist - dist0
       - delta < 0 → DUMMY2 < 0 이어야 하므로 불가능
       - delta % 4 != 0 → 4바이트 단위 맞지 않아 정확히는 불가능
    5) dummy2_nops = delta // 4 후 다시 실행
    """
    print("\n" + "=" * 70)
    print(f"[TARGET] b1=0x{b1_target:x}, b2=0x{b2_target:x}")

    # 1) branch1 정렬
    pad, padfine, b1_aligned = align_branch1(b1_target, pad_init, padfine_init)
    if b1_aligned is None or b1_aligned != b1_target:
        print(
            f"[!] Cannot perfectly align b1 to 0x{b1_target:x}, "
            f"got 0x{b1_aligned:x} instead." if b1_aligned is not None else "[!] b1 alignment failed.",
            file=sys.stderr,
        )
        return

    # 2) dummy2_nops=0 기준 거리 측정
    b1_hex, b2_hex, hit0, conj0, miss0 = run_once(pad, padfine, dummy2_nops=0)
    if not b1_hex or not b2_hex:
        print("[!] Failed to get addresses at dummy2_nops=0", file=sys.stderr)
        return

    b1_0 = int(b1_hex, 16)
    b2_0 = int(b2_hex, 16)
    dist0 = b2_0 - b1_0
    target_dist = b2_target - b1_target

    print(f"[i] baseline: b1={b1_hex}, b2={b2_hex}, dist0={dist0}")
    print(f"[i] target distance = {target_dist}")

    # 3) delta 계산
    delta_bytes = target_dist - dist0
    if delta_bytes < 0:
        print(
            f"[X] Impossible: need DUMMY2 < 0 (delta_bytes={delta_bytes}). "
            f"b2_target가 baseline보다 더 앞에 있어야 함.",
            file=sys.stderr,
        )
        return

    if delta_bytes % 4 != 0:
        print(
            f"[X] Impossible to match exactly: delta_bytes={delta_bytes} is not multiple of 4.",
            file=sys.stderr,
        )
        return

    dummy2_needed = delta_bytes // 4
    print(f"[i] dummy2_nops needed = {dummy2_needed}")

    # 4) 실제 dummy2_nops 적용 후 다시 실행
    b1_hex2, b2_hex2, hit, conj, miss = run_once(pad, padfine, dummy2_nops=dummy2_needed)
    if not b1_hex2 or not b2_hex2:
        print("[!] Failed to get final addresses", file=sys.stderr)
        return

    b1_final = int(b1_hex2, 16)
    b2_final = int(b2_hex2, 16)
    da_final = b1_final ^ b2_final

    print(f"[RESULT] final b1={b1_hex2}, b2={b2_hex2}, da={hex(da_final)}, "
          f"hit={hit}, conj={conj}, miss={miss}")

    # 로그 파일에 기록
    log_result_to_file(b1_hex2, b2_hex2, da_final, hit, conj, miss)


# ---------- main ----------
def main():
    # 첫 실행 시 로그 파일 헤더 초기화
    with open(LOG_FILE, "w") as f:
        f.write("=== Specific Experiment Results ===\n\n")

    if LOOP_FOREVER:
        itr = 0
        while True:
            itr += 1
            print(f"\n========== ITERATION {itr} (infinite) ==========")
            for (b1_raw, b2_raw) in TARGET_PAIRS:
                try:
                    b1_tgt = parse_addr(b1_raw)
                    b2_tgt = parse_addr(b2_raw)
                    run_for_target_pair(b1_tgt, b2_tgt, PAD_INIT, PADFINE1_INIT)
                except Exception as e:
                    print(f"[ERROR] Pair ({b1_raw},{b2_raw}) failed: {e}", file=sys.stderr)
            print(f"[LOOP] Iteration {itr} completed.")
    else:
        for iteration in range(1, NUM_ITER + 1):
            print(f"\n========== ITERATION {iteration}/{NUM_ITER} ==========")
            for (b1_raw, b2_raw) in TARGET_PAIRS:
                try:
                    b1_tgt = parse_addr(b1_raw)
                    b2_tgt = parse_addr(b2_raw)
                    run_for_target_pair(b1_tgt, b2_tgt, PAD_INIT, PADFINE1_INIT)
                except Exception as e:
                    print(f"[ERROR] Pair ({b1_raw},{b2_raw}) failed: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
