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
DB_FILE = Path("res2.db")
ADB_PATH = "/mnt/c/Users/time4/platform-tools/adb.exe"  # 윈도우 adb 경로 (wsl)
BUILD_CMD = ["make"]
PUSH_TARGET = "/data/local/tmp"
BIN_NAME = "test.bin"   # make로 생성되는 파일명
ARCHITECTURE = "Snapdragon865"
CPUNUM = "1"
SETGHR = "1"
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
        miss REAL,
        arch TEXT,
        setghr TEXT
    )
    """)
    conn.commit()
    conn.close()

def insert_record(b1_addr: str, b2_addr: str, da_val: str, avg_hit: float, avg_miss: float, db_path: Path = DB_FILE):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    # 16진수 문자열을 정수로 변환
    b1_int = int(b1_addr, 16) if b1_addr else None
    b2_int = int(b2_addr, 16) if b2_addr else None
    da_int = int(da_val, 16) if da_val else None

    cur.execute(
        "INSERT INTO res (b1a, b2a, da, hit, miss, arch, setghr) VALUES (?, ?, ?, ?, ?, ?, ?)",
        (b1_int, b2_int, da_int, avg_hit, avg_miss, ARCHITECTURE+"-"+CPUNUM, SETGHR)
    )
    conn.commit()
    conn.close()

# ---------- file editing ----------
def replace_nop_repeat_in_region(n_value: int, file_path: Path = BRANCHES_FILE) -> None:
    """
    Replace or insert `NOP_REPEAT(<n_value>);` into the region between
    /* NOP start */ and /* NOP end */ in branches.c.
    If n_value > MAX_NOP_PER_BLOCK, split into multiple NOP_REPEAT blocks.
    """
    content = file_path.read_text()

    # regex to find region (keep the markers)
    pattern = re.compile(r'(/\*\s*NOP start\s*\*/)(.*?)(/\*\s*NOP end\s*\*/)', flags=re.DOTALL)
    m = pattern.search(content)
    if not m:
        raise RuntimeError("Could not find '/* NOP start */ ... /* NOP end */' region in branches.c")

    prefix, region_body, suffix = m.group(1), m.group(2), m.group(3)

    # generate NOP_REPEAT blocks
    blocks = []
    remaining = n_value
    while remaining > 0:
        chunk = min(remaining, MAX_NOP_PER_BLOCK)
        blocks.append(f"NOP_REPEAT({chunk});")
        remaining -= chunk

    new_region = "\n\t" + "\n\t".join(blocks) + "\n\t"

    new_content = content[:m.start()] + prefix + new_region + suffix + content[m.end():]
    file_path.write_text(new_content)

# ---------- adb helpers ----------
def adbwin(*args, capture_output=True, check=True, text=True) -> subprocess.CompletedProcess:
    cmd = [ADB_PATH, *args]
    return subprocess.run(cmd, capture_output=capture_output, check=check, text=text)

def build_binary() -> None:
    subprocess.run(BUILD_CMD, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def push_and_run_on_device() -> str:
    adbwin("push", BIN_NAME, PUSH_TARGET)
    shell_cmd = f"cd {PUSH_TARGET} && chmod +x ./{BIN_NAME} && taskset {CPUNUM} ./{BIN_NAME}"
    cp = adbwin("shell", shell_cmd)
    return cp.stdout

# ---------- parsing & delta address ----------
def parse_output(output_text: str) -> Tuple[Optional[str], Optional[str], Optional[float], Optional[float]]:
    addr1 = None
    addr2 = None
    avg_hit = None
    avg_miss = None

    m1 = re.search(r'address\s+of\s+branch1\s*:\s*(0x[0-9a-fA-F]+)', output_text)
    m2 = re.search(r'address\s+of\s+branch2\s*:\s*(0x[0-9a-fA-F]+)', output_text)
    if m1:
        addr1 = m1.group(1)
    if m2:
        addr2 = m2.group(1)

    mhit = re.search(r'average\s*\(\s*hit\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', output_text, flags=re.IGNORECASE)
    mmiss = re.search(r'average\s*\(\s*miss\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)', output_text, flags=re.IGNORECASE)
    if mhit:
        avg_hit = float(mhit.group(1))
    if mmiss:
        avg_miss = float(mmiss.group(1))

    return addr1, addr2, avg_hit, avg_miss

def delta_address_hex_str(hex_a: str, hex_b: str) -> str:
    """
    XOR-based delta address between b1 and b2.
    Return as hex string.
    """
    if not hex_a or not hex_b:
        return ""
    a = int(hex_a, 16)
    b = int(hex_b, 16)
    xor_val = a ^ b
    return hex(xor_val)

# ---------- experiment runner ----------
def run_experiment_and_store(n_value: int) -> Tuple[str, str, str, Optional[float], Optional[float]]:
    print(f"[+] Running experiment NOP_REPEAT({n_value}) ...")
    replace_nop_repeat_in_region(n_value, BRANCHES_FILE)

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

    b1, b2, avg_hit, avg_miss = parse_output(out)
    da = delta_address_hex_str(b1, b2)

    insert_record(
        b1 if b1 else "",
        b2 if b2 else "",
        da,
        avg_hit if avg_hit is not None else -1.0,
        avg_miss if avg_miss is not None else -1.0
    )

    print(f"[+] Inserted: b1={b1}, b2={b2}, da={da}, hit={avg_hit}, miss={avg_miss}, arch={ARCHITECTURE}-{CPUNUM}, setghr={SETGHR}")
    return b1 if b1 else "", b2 if b2 else "", da, avg_hit, avg_miss

# ---------- main ----------
def main():
    create_db()
    
    # 1: ~857575
    # 2: ~626871
    # 3: ~241777

    for n in [246082]:
        try:
            run_experiment_and_store(n)
        except Exception as e:
            print(f"[!] Experiment for NOP_REPEAT({n}) failed: {e}", file=sys.stderr)
            continue

if __name__ == "__main__":
    main()
