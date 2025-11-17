#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import shutil
import sqlite3
import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple, List, Dict

# ------------ CONFIG ------------
BRANCHES_FILE = Path("branches.c")
MAX_NOP_PER_BLOCK = 8000

DB_FILE = Path("res.db")
ADB_PATH = "/mnt/c/Users/time4/platform-tools/adb.exe"   # WSL에서 Windows adb 실행 경로
BUILD_CMD = ["make"]
PUSH_TARGET = "/data/local/tmp"
BIN_NAME = "test.bin"
ARCHITECTURE = "Snapdragon865"
CPUNUM = "1"
SETGHR = "1"

# 만들고 싶은 타겟 비트 범위 (da == 1<<bit)
BIT_MIN = 3
BIT_MAX = 15

PADFINE1_MAX = 10   # branch1 앞 미세 패드
PADFINE2_MAX = 10   # branch2 앞 미세 패드
MAX_ITER = 30

LOCAL_BIN_DIR = Path("./out_bins")
SUMMARY_PATH = LOCAL_BIN_DIR / "summary.txt"
# --------------------------------


# ---------- DB ----------
def create_db(db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS res (
        b1a INTEGER,
        b2a INTEGER,
        da INTEGER,
        hit REAL,
        miss REAL,
        arch TEXT,
        setghr TEXT,
        target_bit INTEGER,
        target_mask INTEGER,
        nops_pad2 INTEGER,
        nops_padfine2 INTEGER
    )
    """)
    conn.commit()
    conn.close()


def insert_record(b1_addr: str, b2_addr: str, da_val: str,
                  avg_hit: Optional[float], avg_miss: Optional[float],
                  target_bit: Optional[int], target_mask: Optional[int],
                  n_pad2: Optional[int], n_fine2: Optional[int],
                  db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    b1_int = int(b1_addr, 16) if b1_addr else None
    b2_int = int(b2_addr, 16) if b2_addr else None
    da_int = int(da_val, 16) if da_val else None

    cur.execute(
        "INSERT INTO res (b1a, b2a, da, hit, miss, arch, setghr, target_bit, target_mask, nops_pad2, nops_padfine2) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (b1_int, b2_int, da_int,
         avg_hit if avg_hit is not None else -1.0,
         avg_miss if avg_miss is not None else -1.0,
         ARCHITECTURE + "-" + CPUNUM, SETGHR,
         target_bit,
         int(target_mask) if target_mask is not None else None,
         n_pad2, n_fine2)
    )
    conn.commit()
    conn.close()


# ---------- branches.c 패치 (PAD1 / PADFINE1_ENTRY / PAD2 / PADFINE2_ENTRY) ----------
def _emit_nops(n: int) -> str:
    blocks = []
    remaining = max(0, int(n))
    while remaining > 0:
        chunk = min(remaining, MAX_NOP_PER_BLOCK)
        blocks.append(f"NOP_REPEAT({chunk});")
        remaining -= chunk
    if not blocks:
        return "\n\t"
    return "\n\t" + "\n\t".join(blocks) + "\n\t"


def _replace_region(src: str, region: str, nops: int) -> str:
    # 예: /* PAD1 start */ ... /* PAD1 end */
    patt = re.compile(
        rf'(/\*\s*{region}\s*start\s*\*/)(.*?)(/\*\s*{region}\s*end\s*\*/)',
        re.DOTALL
    )
    m = patt.search(src)
    if not m:
        raise RuntimeError(f"Region not found: {region}")
    return src[:m.start()] + m.group(1) + _emit_nops(nops) + m.group(3) + src[m.end():]


def set_pads(pad1: int, padfine1: int, pad2: int, padfine2: int,
             file_path: Path = BRANCHES_FILE):
    pad1 = max(0, int(pad1))
    padfine1 = max(0, min(int(padfine1), PADFINE1_MAX))
    pad2 = max(0, int(pad2))
    padfine2 = max(0, min(int(padfine2), PADFINE2_MAX))

    s = file_path.read_text()
    s = _replace_region(s, "PAD1", pad1)
    s = _replace_region(s, "PADFINE1_ENTRY", padfine1)
    s = _replace_region(s, "PAD2", pad2)
    s = _replace_region(s, "PADFINE2_ENTRY", padfine2)
    file_path.write_text(s)


# ---------- ADB / Build ----------
def adbwin(*args,
           capture_output=True,
           check=True,
           text=True) -> subprocess.CompletedProcess:
    return subprocess.run(
        [ADB_PATH, *args],
        capture_output=capture_output,
        check=check,
        text=text
    )


def build_binary():
    subprocess.run(
        BUILD_CMD,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )


def push_and_run_on_device(bin_name: str = BIN_NAME) -> str:
    adbwin("push", bin_name, PUSH_TARGET)
    cp = adbwin(
        "shell",
        f"cd {PUSH_TARGET} && chmod +x ./{bin_name} "
        f"&& taskset {CPUNUM} ./{bin_name}"
    )
    return cp.stdout


# ---------- Parse output ----------
ADDR1_RE = re.compile(r'address\s+of\s+branch1\s*:\s*(0x[0-9a-fA-F]+)')
ADDR2_RE = re.compile(r'address\s+of\s+branch2\s*:\s*(0x[0-9a-fA-F]+)')
HIT_RE   = re.compile(r'average\s*\(\s*hit\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
                      re.IGNORECASE)
MISS_RE  = re.compile(r'average\s*\(\s*miss\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
                      re.IGNORECASE)


def parse_output(out: str) -> Tuple[Optional[str], Optional[str],
                                    Optional[float], Optional[float]]:
    m1 = ADDR1_RE.search(out)
    m2 = ADDR2_RE.search(out)
    b1 = m1.group(1) if m1 else None
    b2 = m2.group(1) if m2 else None

    mh = HIT_RE.search(out)
    mm = MISS_RE.search(out)
    hit = float(mh.group(1)) if mh else None
    miss = float(mm.group(1)) if mm else None
    return b1, b2, hit, miss


def hex_xor(a_hex: str, b_hex: str) -> str:
    if not a_hex or not b_hex:
        return ""
    return hex(int(a_hex, 16) ^ int(b_hex, 16))


# ---------- Core helpers ----------
def compute_target_mask(bit: int) -> int:
    return 1 << bit


def target_b2(b1_hex: str, bit: int) -> int:
    return int(b1_hex, 16) ^ compute_target_mask(bit)


# ---------- Summary collection ----------
_summary_rows: List[Dict[str, str]] = []


def _add_summary_row(filename: str, b1: Optional[str], b2: Optional[str],
                     target_mask: Optional[int],
                     pad1: int, padfine1: int,
                     pad2: int, padfine2: int):
    _summary_rows.append({
        "filename": filename,
        "b1": b1 or "",
        "b2": b2 or "",
        "target_mask": (f"0x{target_mask:x}" if target_mask is not None else "-"),
        "pad1": str(pad1),
        "padfine1": str(padfine1),
        "pad2": str(pad2),
        "padfine2": str(padfine2),
    })


def _write_summary_file():
    LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)
    lines = []
    lines.append("# out_bins summary")
    lines.append("# filename, b1, b2, target_mask, "
                 "PAD1_NOPs, PADFINE1_NOPs, PAD2_NOPs, PADFINE2_NOPs")
    for row in _summary_rows:
        lines.append(
            f"{row['filename']}, {row['b1']}, {row['b2']}, {row['target_mask']}, "
            f"{row['pad1']}, {row['padfine1']}, {row['pad2']}, {row['padfine2']}"
        )
    SUMMARY_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"[✓] Wrote summary to {SUMMARY_PATH}")


# ---------- One build & run ----------
def one_build_run(pad1: int, padfine1: int,
                  pad2: int, padfine2: int,
                  target_bit: Optional[int],
                  save_copy_name: Optional[str] = None
                  ) -> Tuple[str, str, str, Optional[float], Optional[float]]:
    """
    주어진 패딩 값으로 branches.c를 갱신 → 빌드 → 실행 → 주소/latency 파싱.
    target_bit이 주어지면 da 목표 mask를 DB에 기록용으로만 남긴다.
    """
    set_pads(pad1, padfine1, pad2, padfine2)
    build_binary()

    if save_copy_name:
        LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / save_copy_name)

    out = push_and_run_on_device(BIN_NAME)
    b1, b2, hit, miss = parse_output(out)
    da = hex_xor(b1, b2)
    mask = compute_target_mask(target_bit) if target_bit is not None else None

    insert_record(b1 or "", b2 or "", da, hit, miss,
                  target_bit, mask,
                  pad2, padfine2)

    print(f"[+] PAD1={pad1}, F1={padfine1}, "
          f"PAD2={pad2}, F2={padfine2} :: "
          f"b1={b1}, b2={b2}, da={da}, hit={hit}, miss={miss}, "
          f"target={hex(mask) if mask is not None else None}")

    if save_copy_name:
        _add_summary_row(save_copy_name, b1, b2, mask,
                         pad1, padfine1, pad2, padfine2)

    return b1 or "", b2 or "", da, hit, miss


# ---------- Step1: branch1의 target_bit를 0으로 만들기 ----------
def solve_branch1_bit_zero(target_bit: int,
                           pad1_init: int = 0,
                           padfine1_init: int = 0
                           ) -> Tuple[int, int, str]:
    """
    branch1 주소의 target_bit를 0으로 만드는 최소 PAD1/PADFINE1 조합을 찾는다.
    (NOP은 '앞에 더 붙이는' 방향으로만 생각하고, 총 개수 최소화.)
    """
    pad1 = max(0, int(pad1_init))
    padfine1 = max(0, int(padfine1_init))

    # 현재 상태 측정 (PAD2/PADFINE2는 0으로)
    b1, _, _, _ = one_build_run(pad1, padfine1, 0, 0, None)[0:4]
    if not b1:
        raise RuntimeError("Failed to get branch1 address while aligning.")

    addr = int(b1, 16)
    if ((addr >> target_bit) & 1) == 0:
        print(f"[i] bit{target_bit}: branch1 already has bit=0 "
              f"(PAD1={pad1}, F1={padfine1})")
        return pad1, padfine1, b1

    if target_bit < 2:
        raise ValueError("target_bit < 2 not supported (4-byte alignment).")

    # 주소를 word(4-byte) 단위로 보고, 해당 비트를 1→0으로 바뀔 때까지
    bit_word = target_bit - 2
    w = addr >> 2
    mask = (1 << bit_word) - 1
    offset = w & mask
    need_words = (1 << bit_word) - offset   # 다음 'bit=0 구간' 시작까지

    total_nops = need_words

    if total_nops <= PADFINE1_MAX:
        pad1 = 0
        padfine1 = total_nops
    else:
        pad1 = total_nops - PADFINE1_MAX
        padfine1 = PADFINE1_MAX

    print(f"[i] bit{target_bit}: add total {total_nops} NOPs before branch1 "
          f"-> PAD1={pad1}, F1={padfine1}")

    b1_new, _, _, _ = one_build_run(pad1, padfine1, 0, 0, None)[0:4]
    if not b1_new:
        raise RuntimeError("Failed to get branch1 address after alignment.")

    if ((int(b1_new, 16) >> target_bit) & 1) != 0:
        raise RuntimeError(
            f"Alignment failed for bit {target_bit}, got b1={b1_new}"
        )

    return pad1, padfine1, b1_new


# ---------- Step2: PAD2/PADFINE2로 da == (1<<bit) 만들기 ----------
def solve_for_bit(bit: int,
                  pad1_init: int = 0,
                  padfine1_init: int = 0
                  ) -> Optional[Tuple[int, int, int, int]]:
    """
    1) PAD1/PADFINE1으로 b1의 bit를 0으로 맞추고
    2) 그 상태를 고정한 채, PAD2/PADFINE2만 조정해서
       da = b1 ^ b2 == (1<<bit) 를 만족시키는 레이아웃 탐색.
    성공 시 (pad1, padfine1, pad2, padfine2) 반환.
    """
    print(f"\n[>] Solve for single-bit XOR: bit={bit}, "
          f"target_mask={hex(compute_target_mask(bit))}")

    pad1, padfine1, b1_hex = solve_branch1_bit_zero(
        bit, pad1_init, padfine1_init
    )

    target_mask = compute_target_mask(bit)

    pad2 = 0
    padfine2 = 0

    b1, b2, da, *_ = one_build_run(
        pad1, padfine1, pad2, padfine2, bit
    )
    if not (b1 and b2):
        return None

    for _ in range(MAX_ITER):
        if not (b1 and b2 and da):
            break

        b1_val = int(b1, 16)
        b2_val = int(b2, 16)
        da_val = int(da, 16)

        if da_val == target_mask:
            # 성공
            final_name = f"test.bit{bit}.bin"
            shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
            _add_summary_row(
                final_name, b1, b2, target_mask,
                pad1, padfine1, pad2, padfine2
            )
            print(f"[✓] bit={bit}: SOLVED with "
                  f"PAD1={pad1}, F1={padfine1}, PAD2={pad2}, F2={padfine2}")
            return pad1, padfine1, pad2, padfine2

        target_b2_val = b1_val ^ target_mask
        delta_bytes = target_b2_val - b2_val

        if delta_bytes == 0:
            # XOR는 다른 비트 때문일 수 있으니, 미세하게 한 칸 이동
            padfine2 = min(PADFINE2_MAX, padfine2 + 1)
        elif delta_bytes > 4 * PADFINE2_MAX:
            # coarse PAD2로 크게 이동
            step_nops = (delta_bytes // 4) - PADFINE2_MAX
            step_nops = max(1, step_nops)
            pad2 = max(0, pad2 + step_nops)
        elif delta_bytes > 0:
            # fine2로 마무리
            padfine2 = min(PADFINE2_MAX,
                           max(0, (delta_bytes + 3) // 4))
        else:  # delta_bytes < 0 → 현재 b2가 target_b2보다 너무 뒤에 있음
            step_nops = max(1, (abs(delta_bytes) // 4))
            if pad2 >= step_nops:
                pad2 -= step_nops
            else:
                pad2 = 0
                # PAD2=0에서도 이미 target보다 큰 경우 → 이 bit에 대해서는
                # branch1 쪽을 더 밀지 않고는 불가능하므로 실패 처리.
                print(f"[!] bit={bit}: target_b2 < current b2 even with PAD2=0. "
                      f"Give up for this bit.")
                break

        # 업데이트 후 재측정
        b1, b2, da, *_ = one_build_run(
            pad1, padfine1, pad2, padfine2, bit
        )

    print(f"[x] bit={bit}: failed to solve within {MAX_ITER} iterations.")
    return None


# ---------- main ----------
def main():
    create_db()
    LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)

    # Baseline 저장
    print("[+] Baseline")
    b1, b2, da, *_ = one_build_run(
        0, 0, 0, 0, None,
        save_copy_name="test.baseline.bin"
    )
    if not (b1 and b2):
        print("[!] Baseline failed: missing addresses")
        sys.exit(1)
    print(f"[i] baseline: b1={b1}, b2={b2}, da={da}")

    pad1_state = 0
    padfine1_state = 0

    # 각 bit에 대해 독립적인 바이너리 생성
    for bit in range(BIT_MIN, BIT_MAX + 1):
        res = solve_for_bit(bit, pad1_state, padfine1_state)
        # 다음 bit에서 branch1을 더 앞당기고 싶지 않으면, pad1_state 업데이트 안 해도 됨
        if res is not None:
            pad1_state, padfine1_state, _, _ = res

    _write_summary_file()


if __name__ == "__main__":
    main()
