#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math
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

BIT_HI = 25
BIT_LO_MIN = 3
BIT_LO_MAX = 15

ENTRY_MAX = 10
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
        target_bit_hi INTEGER,
        target_bit_lo INTEGER,
        target_mask INTEGER,
        nops_pad20 INTEGER,
        nops_padfine_entry INTEGER
    )
    """)
    conn.commit()
    conn.close()

def insert_record(b1_addr: str, b2_addr: str, da_val: str,
                  avg_hit: Optional[float], avg_miss: Optional[float],
                  bit_hi: Optional[int], bit_lo: Optional[int], target_mask: Optional[int],
                  n_pad20: Optional[int], n_entry: Optional[int],
                  db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    b1_int = int(b1_addr, 16) if b1_addr else None
    b2_int = int(b2_addr, 16) if b2_addr else None
    da_int = int(da_val, 16) if da_val else None
    cur.execute(
        "INSERT INTO res (b1a, b2a, da, hit, miss, arch, setghr, target_bit_hi, target_bit_lo, target_mask, nops_pad20, nops_padfine_entry) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (b1_int, b2_int, da_int,
         avg_hit if avg_hit is not None else -1.0,
         avg_miss if avg_miss is not None else -1.0,
         ARCHITECTURE + "-" + CPUNUM, SETGHR,
         bit_hi, bit_lo, int(target_mask) if target_mask is not None else None,
         n_pad20, n_entry)
    )
    conn.commit()
    conn.close()

# ---------- Edit branches.c (PAD20 + ENTRY) ----------
def _emit_nops(n: int) -> str:
    blocks = []
    remaining = max(0, int(n))
    while remaining > 0:
        chunk = min(remaining, MAX_NOP_PER_BLOCK)
        blocks.append(f"NOP_REPEAT({chunk});")
        remaining -= chunk
    return ("\n\t" + "\n\t".join(blocks) + "\n\t") if blocks else "\n\t"

def _replace_region(src: str, region: str, nops: int) -> str:
    patt = re.compile(rf'(/\*\s*{region}\s+start\s*\*/)(.*?)(/\*\s*{region}\s+end\s*\*/)', re.DOTALL)
    m = patt.search(src)
    if not m:
        raise RuntimeError(f"Region not found: {region}")
    return src[:m.start()] + m.group(1) + _emit_nops(nops) + m.group(3) + src[m.end():]

def set_pads(n20: int, n_entry: int, file_path: Path = BRANCHES_FILE):
    n20 = max(0, int(n20))
    n_entry = max(0, min(int(n_entry), ENTRY_MAX))
    s = file_path.read_text()
    s = _replace_region(s, "PAD20", n20)
    s = _replace_region(s, "PADFINE_ENTRY", n_entry)
    file_path.write_text(s)

# ---------- ADB / Build ----------
def adbwin(*args, capture_output=True, check=True, text=True) -> subprocess.CompletedProcess:
    return subprocess.run([ADB_PATH, *args], capture_output=capture_output, check=check, text=text)

def build_binary():
    subprocess.run(BUILD_CMD, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def push_and_run_on_device(bin_name: str = BIN_NAME) -> str:
    adbwin("push", bin_name, PUSH_TARGET)
    cp = adbwin("shell", f"cd {PUSH_TARGET} && chmod +x ./{bin_name} && taskset {CPUNUM} ./{bin_name}")
    return cp.stdout

# ---------- Parse output ----------
ADDR1_RE = re.compile(r'address\s+of\s+branch1\s*:\s*(0x[0-9a-fA-F]+)')
ADDR2_RE = re.compile(r'address\s+of\s+branch2\s*:\s*(0x[0-9a-fA-F]+)')
HIT_RE   = re.compile(r'average\s*\(\s*hit\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', re.IGNORECASE)
MISS_RE  = re.compile(r'average\s*\(\s*miss\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', re.IGNORECASE)

def parse_output(out: str) -> Tuple[Optional[str], Optional[str], Optional[float], Optional[float]]:
    m1 = ADDR1_RE.search(out); m2 = ADDR2_RE.search(out)
    b1 = m1.group(1) if m1 else None
    b2 = m2.group(1) if m2 else None
    mh = HIT_RE.search(out); mm = MISS_RE.search(out)
    hit = float(mh.group(1)) if mh else None
    miss = float(mm.group(1)) if mm else None
    return b1, b2, hit, miss

def hex_xor(a_hex: str, b_hex: str) -> str:
    if not a_hex or not b_hex: return ""
    return hex(int(a_hex, 16) ^ int(b_hex, 16))

# ---------- Core helpers ----------
def compute_target_mask(bit_lo: int) -> int:
    return (1 << BIT_HI) ^ (1 << bit_lo)

def target_b2(b1_hex: str, bit_lo: int) -> int:
    return int(b1_hex, 16) ^ compute_target_mask(bit_lo)

# ---------- Summary collection ----------
_summary_rows: List[Dict[str, str]] = []

def _add_summary_row(filename: str, b1: Optional[str], b2: Optional[str],
                     target_mask: Optional[int], n20: int, n_entry: int):
    _summary_rows.append({
        "filename": filename,
        "b1": b1 or "",
        "b2": b2 or "",
        "target_mask": (f"0x{target_mask:x}" if target_mask is not None else "-"),
        "pad20": str(n20),
        "entry": str(n_entry),
    })

def _write_summary_file():
    LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)
    lines = []
    lines.append("# out_bins summary")
    lines.append("# filename, b1, b2, target_mask, PAD20_NOPs, ENTRY_NOPs")
    for row in _summary_rows:
        lines.append(f"{row['filename']}, {row['b1']}, {row['b2']}, {row['target_mask']}, {row['pad20']}, {row['entry']}")
    SUMMARY_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"[✓] Wrote summary to {SUMMARY_PATH}")

# ---------- One build & run (explicit mask override 지원) ----------
def one_build_run(n20: int, n_entry: int,
                  bit_lo: Optional[int],
                  save_copy_name: Optional[str] = None,
                  target_mask_override: Optional[int] = None) -> Tuple[str, str, str, Optional[float], Optional[float]]:
    mask = target_mask_override if target_mask_override is not None else (compute_target_mask(bit_lo) if bit_lo is not None else None)
    set_pads(n20, n_entry)
    build_binary()
    if save_copy_name:
        LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / save_copy_name)
    out = push_and_run_on_device(BIN_NAME)
    b1, b2, hit, miss = parse_output(out)
    da = hex_xor(b1, b2)
    insert_record(b1 or "", b2 or "", da, hit, miss,
                  BIT_HI if mask is not None else None,
                  (bit_lo if (bit_lo is not None and target_mask_override is None) else None),
                  mask, n20, n_entry)
    print(f"[+] PAD20={n20}, ENTRY={n_entry} :: b1={b1}, b2={b2}, da={da}, hit={hit}, miss={miss}, target={hex(mask) if mask is not None else None}")
    if save_copy_name:
        _add_summary_row(save_copy_name, b1, b2, mask, n20, n_entry)
    return b1 or "", b2 or "", da, hit, miss

# ---------- Solver: bit_hi only ----------
def solve_hi_only(pad20_init: int = 0) -> Optional[Tuple[int, int]]:
    """
    da == (1<<BIT_HI)만 만족하는 케이스를 생성.
    pad20을 증/감해 b2를 목표 근처로 보내고, entry(≤ENTRY_MAX)로 마무리.
    결과는 out_bins/test.bit{BIT_HI}_only.bin 저장.
    """
    mask = (1 << BIT_HI)
    n20 = max(0, int(pad20_init))
    n_entry = 0

    b1, b2, da, *_ = one_build_run(n20, 0, None, save_copy_name=None, target_mask_override=mask)
    if not (b1 and b2):
        return None

    b2_now = int(b2, 16)
    b2_goal = int(b1, 16) ^ mask

    for _ in range(MAX_ITER):
        delta_bytes = b2_goal - b2_now
        if delta_bytes < 0:
            step_nops = min(n20, (-delta_bytes + 3)//4)
            if step_nops == 0:
                break
            n20 -= step_nops
        elif delta_bytes > 4 * ENTRY_MAX:
            step_nops = (delta_bytes // 4) - ENTRY_MAX
            step_nops = max(1, step_nops)
            n20 += step_nops
        else:
            n_entry = (delta_bytes + 3)//4 if delta_bytes > 0 else 0
            n_entry = min(max(0, n_entry), ENTRY_MAX)

            b1, b2, da, *_ = one_build_run(n20, n_entry, None, save_copy_name=None, target_mask_override=mask)
            if da and int(da, 16) == mask:
                final_name = f"test.bit{BIT_HI}_only.bin"
                shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
                _add_summary_row(final_name, b1, b2, mask, n20, n_entry)
                print(f"[✓] hi-only: SOLVED with PAD20={n20}, ENTRY={n_entry}")
                return n20, n_entry

            # ENTRY 미세 보정
            for tweak in [1,2,3]:
                for sign in (+1, -1):
                    trial_entry = n_entry + sign*tweak
                    if trial_entry < 0 or trial_entry > ENTRY_MAX: continue
                    b1t, b2t, dat, *_ = one_build_run(n20, trial_entry, None, save_copy_name=None, target_mask_override=mask)
                    if dat and int(dat, 16) == mask:
                        final_name = f"test.bit{BIT_HI}_only.bin"
                        shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
                        _add_summary_row(final_name, b1t, b2t, mask, n20, trial_entry)
                        print(f"[✓] hi-only: SOLVED after entry tweak -> PAD20={n20}, ENTRY={trial_entry}")
                        return n20, trial_entry

            # pad20을 소폭 조정
            n20 = max(0, n20 + 1)

        # pad20 조정 후 재측정
        b1, b2, da, *_ = one_build_run(n20, 0, None, save_copy_name=None, target_mask_override=mask)
        if not (b1 and b2): break
        b2_now = int(b2, 16)

    print("[x] hi-only: failed to solve within iteration limit.")
    return None

# ---------- Solver per target (pad20 앞뒤로, entry로 마무리) ----------
def solve_target(bit_lo: int, pad20_init: int = 0) -> Optional[Tuple[int, int]]:
    """
    da == (1<<BIT_HI) ^ (1<<bit_lo)
    1) pad20을 증/감해 b2를 b2_target 이하로 근접
    2) entry(≤ENTRY_MAX)로 최종 마무리
    """
    n20 = max(0, int(pad20_init))
    n_entry = 0

    b1, b2, da, *_ = one_build_run(n20, 0, bit_lo, save_copy_name=None)
    if not (b1 and b2): 
        return None

    b2_now = int(b2, 16)
    b2_goal = target_b2(b1, bit_lo)

    for _ in range(MAX_ITER):
        delta_bytes = b2_goal - b2_now

        if delta_bytes < 0:
            step_nops = min(n20, (-delta_bytes + 3)//4)
            if step_nops == 0:
                break
            n20 -= step_nops
        elif delta_bytes > 4 * ENTRY_MAX:
            step_nops = (delta_bytes // 4) - ENTRY_MAX
            step_nops = max(1, step_nops)
            n20 += step_nops
        else:
            n_entry = (delta_bytes + 3) // 4 if delta_bytes > 0 else 0
            n_entry = min(max(0, n_entry), ENTRY_MAX)

            b1, b2, da, *_ = one_build_run(n20, n_entry, bit_lo, save_copy_name=None)
            if da and int(da, 16) == compute_target_mask(bit_lo):
                final_name = f"test.bit{BIT_HI}_x{bit_lo}.bin"
                shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
                _add_summary_row(final_name, b1, b2, compute_target_mask(bit_lo), n20, n_entry)
                print(f"[✓] bit_lo={bit_lo}: SOLVED with PAD20={n20}, ENTRY={n_entry}")
                return n20, n_entry

            # ENTRY ±1..±3 미세 보정
            for tweak in [1,2,3]:
                for sign in (+1, -1):
                    trial_entry = n_entry + sign*tweak
                    if trial_entry < 0 or trial_entry > ENTRY_MAX:
                        continue
                    b1t, b2t, dat, *_ = one_build_run(n20, trial_entry, bit_lo, save_copy_name=None)
                    if dat and int(dat, 16) == compute_target_mask(bit_lo):
                        final_name = f"test.bit{BIT_HI}_x{bit_lo}.bin"
                        shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
                        _add_summary_row(final_name, b1t, b2t, compute_target_mask(bit_lo), n20, trial_entry)
                        print(f"[✓] bit_lo={bit_lo}: SOLVED after entry tweak -> PAD20={n20}, ENTRY={trial_entry}")
                        return n20, trial_entry

            n20 = max(0, n20 + 1)

        b1, b2, da, *_ = one_build_run(n20, 0, bit_lo, save_copy_name=None)
        if not (b1 and b2): 
            break
        b2_now = int(b2, 16)

    print(f"[x] bit_lo={bit_lo}: failed to solve within {MAX_ITER} iterations.")
    return None

# ---------- main ----------
def main():
    create_db()
    LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)

    # Baseline 저장
    print("[+] Baseline")
    b1, b2, *_ = one_build_run(0, 0, None, save_copy_name="test.baseline.bin", target_mask_override=None)
    if not (b1 and b2):
        print("[!] Baseline failed: missing addresses")
        sys.exit(1)
    print(f"[i] baseline: b1={b1}, b2={b2}, da={hex_xor(b1,b2)}")

    # bit_hi only 케이스
    print(f"\n[>] Solve hi-only for bit_hi={BIT_HI}, target_mask={hex(1<<BIT_HI)}")
    hi_res = solve_hi_only(pad20_init=0)

    # 각 x에 대해: pad20 앞/뒤 이동 → entry로 마무리
    pad20_state = 0 if hi_res is None else hi_res[0]
    for x in range(BIT_LO_MIN, BIT_LO_MAX + 1):
        print(f"\n[>] Solve for bit_hi={BIT_HI}, bit_lo={x}, target_mask={hex((1<<BIT_HI)^(1<<x))}")
        res = solve_target(x, pad20_state)
        if res is not None:
            pad20_state, _ = res
        else:
            print(f"[skip] bit_lo={x}: could not solve with given layout.")

    # 요약 파일 작성
    _write_summary_file()

if __name__ == "__main__":
    main()
