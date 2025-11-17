#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import sqlite3
import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple

# ------------ CONFIG ------------
BRANCHES_FILE = Path("branches.c")
MAX_NOP_PER_BLOCK = 8000  # .rept 제한

DB_FILE = Path("res.db")
ADB_PATH = "/mnt/c/Users/time4/platform-tools/adb.exe"  # 윈도우 adb 경로 (WSL)
BUILD_CMD = ["make"]
PUSH_TARGET = "/data/local/tmp"
BIN_NAME = "test.bin"   # make로 생성되는 파일명
ARCHITECTURE = "Snapdragon865"
CPUNUM = "1"
SETGHR = "0"

# branch1을 고정하고 싶은 절대 주소
TARGET_B1_ADDR_HEX = "0x402258"
TARGET_B1_ADDR_INT = int(TARGET_B1_ADDR_HEX, 16)

PADFINE1_MAX = 10       # PADFINE1은 NOP 10개 이하
ALIGN_MAX_ITER = 30     # branch1 정렬 최대 반복
# --------------------------------


# ---------- DB helpers ----------
def create_db(db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS res (
        b1a INTEGER,
        b2a INTEGER,
        da INTEGER,
        hit REAL,
        conj REAL,
        miss REAL,
        arch TEXT,
        setghr TEXT
    )
    """)
    conn.commit()
    conn.close()


def insert_record(b1_addr: str,
                  b2_addr: str,
                  da_val: str,
                  avg_hit: Optional[float],
                  avg_conj: Optional[float],
                  avg_miss: Optional[float],
                  db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    b1_int = int(b1_addr, 16) if b1_addr else None
    b2_int = int(b2_addr, 16) if b2_addr else None
    da_int = int(da_val, 16) if da_val else None

    cur.execute(
        "INSERT INTO res (b1a, b2a, da, hit, conj, miss, arch, setghr) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        (
            b1_int,
            b2_int,
            da_int,
            avg_hit if avg_hit is not None else -1.0,
            avg_conj if avg_conj is not None else -1.0,
            avg_miss if avg_miss is not None else -1.0,
            ARCHITECTURE + "-" + CPUNUM,
            SETGHR,
        ),
    )
    conn.commit()
    conn.close()


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


def _replace_region(region_name: str,
                    n_value: int,
                    max_nops_total: Optional[int] = None,
                    file_path: Path = BRANCHES_FILE) -> None:
    """
    region_name:
      - "PAD"              → dummy1:  /* PAD start */ ~ /* PAD end */
      - "PADFINE1_ENTRY"   → branch1: /* PADFINE1_ENTRY start */ ~ /* PADFINE1_ENTRY end */
      - "NOP"              → dummy2:  /* NOP start */ ~ /* NOP end */
    max_nops_total: 총 NOP 개수 상한 (예: PADFINE1_ENTRY용 10)
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
    """branch1 앞 PADFINE1_ENTRY 영역 NOP 개수 세팅 (≤ 10)."""
    _replace_region("PADFINE1_ENTRY", padfine_nops, max_nops_total=PADFINE1_MAX)


def set_dummy2_nops(n_value: int) -> None:
    """dummy2 안의 /* NOP start */ ~ /* NOP end */ NOP 개수 세팅."""
    _replace_region("NOP", n_value)


# ---------- adb & build ----------
def adbwin(*args, capture_output=True, check=True, text=True) -> subprocess.CompletedProcess:
    cmd = [ADB_PATH, *args]
    return subprocess.run(cmd, capture_output=capture_output, check=check, text=text)


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


# ---------- parsing & delta address ----------
def parse_output(output_text: str) -> Tuple[
    Optional[str],
    Optional[str],
    Optional[float],
    Optional[float],
    Optional[float],
]:
    """
    출력 포맷:

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

    mhit = re.search(
        r'average\s*\(\s*0000-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
        output_text,
        flags=re.IGNORECASE,
    )
    mconj = re.search(
        r'average\s*\(\s*0001-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
        output_text,
        flags=re.IGNORECASE,
    )
    mmiss = re.search(
        r'average\s*\(\s*0000-b2-0\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
        output_text,
        flags=re.IGNORECASE,
    )

    if mhit:
        avg_hit = float(mhit.group(1))
    if mconj:
        avg_conj = float(mconj.group(1))
    if mmiss:
        avg_miss = float(mmiss.group(1))

    return addr1, addr2, avg_hit, avg_conj, avg_miss


def delta_address_hex_str(hex_a: str, hex_b: str) -> str:
    """XOR 기반 delta address (b1 ^ b2)."""
    if not hex_a or not hex_b:
        return ""
    a = int(hex_a, 16)
    b = int(hex_b, 16)
    xor_val = a ^ b
    return hex(xor_val)


# ---------- single experiment ----------
def run_single_experiment(pad_nops: int,
                          padfine_nops: int,
                          dummy2_nops: int) -> Tuple[
                              str,
                              str,
                              str,
                              Optional[float],
                              Optional[float],
                              Optional[float],
                          ]:
    """
    - dummy1 PAD = pad_nops
    - branch1 PADFINE1_ENTRY = padfine_nops (≤ 10)
    - dummy2 NOP = dummy2_nops
    로 설정한 뒤 빌드 + 실행 + 파싱 + DB insert.
    """
    set_pad(pad_nops)
    set_padfine1(padfine_nops)
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
    da = delta_address_hex_str(b1, b2)

    insert_record(
        b1 if b1 else "",
        b2 if b2 else "",
        da,
        avg_hit,
        avg_conj,
        avg_miss,
    )

    print(
        f"[+] PAD={pad_nops}, PADFINE1={padfine_nops}, DUMMY2_NOP={dummy2_nops} :: "
        f"b1={b1}, b2={b2}, da={da}, "
        f"hit={avg_hit}, conj={avg_conj}, miss={avg_miss}, "
        f"arch={ARCHITECTURE}-{CPUNUM}, setghr={SETGHR}"
    )

    return (
        b1 if b1 else "",
        b2 if b2 else "",
        da,
        avg_hit,
        avg_conj,
        avg_miss,
    )


# ---------- branch1 정렬 (b1 == 0x402258 만들기) ----------
def align_branch1_to_target(pad_init: int,
                            padfine_init: int) -> Tuple[int, int, str]:
    """
    dummy1의 PAD와 branch1의 PADFINE1_ENTRY를 조절해서
    branch1 주소를 TARGET_B1_ADDR_HEX(=0x402258)로 맞춘다.

    - PADFINE1은 최대 10 NOP까지만 사용, 나머지는 PAD로 보정
    - 4바이트 단위로만 증가한다고 가정 (nop 1개 = 4바이트)
    - 한 번에 DUMMY2_NOP은 0으로 고정 (b2 영향은 정렬할 때는 신경 안 씀)
    """
    pad = max(0, int(pad_init))
    padfine = max(0, int(padfine_init))

    print(f"[i] Align branch1 to {TARGET_B1_ADDR_HEX} (start PAD={pad}, PADFINE1={padfine})")

    last_b1 = ""

    for _ in range(ALIGN_MAX_ITER):
        # dummy2_nops=0 상태에서 측정
        b1, _, _, _, _, _ = run_single_experiment(pad, padfine, dummy2_nops=0)
        last_b1 = b1

        if not b1:
            print("[!] align: failed to get branch1 address.", file=sys.stderr)
            break

        cur = int(b1, 16)
        if cur == TARGET_B1_ADDR_INT:
            print(f"[✓] branch1 aligned: b1={b1}, PAD={pad}, PADFINE1={padfine}")
            return pad, padfine, b1

        if cur > TARGET_B1_ADDR_INT:
            # 앞으로만 밀 수 있는 구조라면 이 경우는 더 이상 맞출 수 없음
            print(
                f"[!] align: current b1={b1} > target={TARGET_B1_ADDR_HEX}, "
                f"cannot adjust further by adding NOPs only.",
                file=sys.stderr,
            )
            break

        delta_bytes = TARGET_B1_ADDR_INT - cur
        # 필요한 NOP 개수 (4바이트 단위)
        add_nops = (delta_bytes + 3) // 4

        # 먼저 PADFINE1 여유분 사용 (≤ 10)
        room_fine = PADFINE1_MAX - padfine
        use_fine = min(add_nops, max(0, room_fine))
        padfine += use_fine
        pad += (add_nops - use_fine)

        print(
            f"[i] align step: b1={b1}, delta_bytes={delta_bytes}, add_nops={add_nops}, "
            f"→ PAD={pad}, PADFINE1={padfine}"
        )

    print(
        f"[x] align: failed to converge to {TARGET_B1_ADDR_HEX}, last b1={last_b1}",
        file=sys.stderr,
    )
    return pad, padfine, last_b1


# ---------- main ----------
def main():
    create_db()

    # 초기 PAD / PADFINE1 상태
    # branches.c에 처음 넣어둔 dummy1이 NOP_REPEAT(39); 라고 했으니
    # 그에 맞춰 시작 (PAD=39, PADFINE1=0)
    pad_state = 39
    padfine_state = 0

    for i in range(0, 10):
        print(f"\n[===== ROUND {i} : align branch1 & sweep dummy2 NOP =====]")

        # 먼저 branch1을 0x402258로 정렬
        pad_state, padfine_state, b1_fixed = align_branch1_to_target(
            pad_state,
            padfine_state,
        )
        print(f"[i] after align: b1={b1_fixed}, PAD={pad_state}, PADFINE1={padfine_state}")

        if b1_fixed and int(b1_fixed, 16) != TARGET_B1_ADDR_INT:
            print(
                f"[!] WARNING: b1={b1_fixed} != {TARGET_B1_ADDR_HEX} "
                f"(alignment may have failed).",
                file=sys.stderr,
            )

        # dummy2 NOP 개수를 0부터 99999까지 늘려가며 실험
        for n in range(0, 100000):
            try:
                b1, b2, da, avg_hit, avg_conj, avg_miss = run_single_experiment(
                    pad_state,
                    padfine_state,
                    dummy2_nops=n,
                )
            except Exception as e:
                print(f"[!] Experiment dummy2 NOP={n} failed: {e}", file=sys.stderr)
                continue

            # 실행 중에 b1이 target에서 벗어나면 로그만 남김
            if b1 and int(b1, 16) != TARGET_B1_ADDR_INT:
                print(
                    f"[!] b1={b1} != {TARGET_B1_ADDR_HEX} "
                    f"(PAD={pad_state}, PADFINE1={padfine_state})",
                    file=sys.stderr,
                )
                # 필요하면 여기서 즉시 재-align 호출하도록 바꿀 수 있음.

    print("[*] Done.")


if __name__ == "__main__":
    main()
