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
DB_FILE = Path("res_b1.db")
ADB_PATH = "/mnt/c/Users/time4/platform-tools/adb.exe"  # 윈도우 adb 경로 (wsl)
BUILD_CMD = ["make"]
PUSH_TARGET = "/data/local/tmp"
BIN_NAME = "test.bin"   # make로 생성되는 파일명
ARCHITECTURE = "Snapdragon865"
CPUNUM = "1"
SETGHR = "0"
# --------------------------------

# ---------- DB helpers ----------

def create_db(db_path: Path = DB_FILE) -> None:
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS res (
        src  INTEGER,
        tgt  INTEGER,
        h4m0 REAL,
        h3m1 REAL,
        h2m2 REAL,
        h1m3 REAL,
        h0m4 REAL
    )
    """)
    conn.commit()
    conn.close()


def insert_record(
    src_addr: str,
    tgt_addr: str,
    h4m0: Optional[float],
    h3m1: Optional[float],
    h2m2: Optional[float],
    h1m3: Optional[float],
    h0m4: Optional[float],
    db_path: Path = DB_FILE,
) -> None:
    """
    src_addr, tgt_addr: "0x402194" 같은 hex 문자열 또는 ""/None
    h4m0 ~ h0m4: float 또는 None (없으면 NULL로 들어감)
    """
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    src_int = int(src_addr, 16) if src_addr else None
    tgt_int = int(tgt_addr, 16) if tgt_addr else None

    cur.execute(
        """
        INSERT INTO res (src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (src_int, tgt_int, h4m0, h3m1, h2m2, h1m3, h0m4),
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

def adbwin(*args, capture_output: bool = True, check: bool = True, text: bool = True) -> subprocess.CompletedProcess:
    cmd = [ADB_PATH, *args]
    return subprocess.run(cmd, capture_output=capture_output, check=check, text=text)


def build_binary() -> None:
    subprocess.run(BUILD_CMD, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def push_and_run_on_device() -> str:
    # push
    print(f"[+] Pushing ./{BIN_NAME} → {PUSH_TARGET}/{BIN_NAME} ...")
    adbwin("push", BIN_NAME, f"{PUSH_TARGET}/{BIN_NAME}")
    # chmod + 실행
    print("[+] Setting executable permission ...")
    shell_cmd = f"cd {PUSH_TARGET} && chmod +x ./{BIN_NAME} && echo '[+] Running on CPU {CPUNUM} ...' && taskset {CPUNUM} ./{BIN_NAME}"
    cp = adbwin("shell", shell_cmd)
    return cp.stdout


# ---------- parsing ----------

def parse_output(output_text: str):
    """
    test.bin의 stdout에서
      - src, tgt 주소
      - average(0000-0) ~ average(1111-0)의 평균값
    을 파싱해서 돌려준다.

    예시:
      address of branch1(src): 0x402194
      address of branch2(tgt): 0x4021a0
      average (0000-0): 2.00 (0.00)
      ...
    """
    src = None
    tgt = None

    # address of branch1(src): 0x402194
    m_src = re.search(
        r'address\s+of\s+branch1\(src\)\s*:\s*(0x[0-9a-fA-F]+)',
        output_text
    )
    if m_src:
        src = m_src.group(1)

    # address of branch2(tgt): 0x4021a0
    m_tgt = re.search(
        r'address\s+of\s+branch2\(tgt\)\s*:\s*(0x[0-9a-fA-F]+)',
        output_text
    )
    if m_tgt:
        tgt = m_tgt.group(1)

    # average (0000-0): 2.00 (0.00)  이런 형식들
    tag_to_col = {
        "0000-0": "h4m0",
        "0001-0": "h3m1",
        "0011-0": "h2m2",
        "0111-0": "h1m3",
        "1111-0": "h0m4",
    }
    vals = {name: None for name in tag_to_col.values()}

    avg_pattern = re.compile(
        r'average\s*\(\s*([01]{4}-[01])\s*\)\s*:\s*([0-9]+(?:\.[0-9]+)?)',
        flags=re.IGNORECASE
    )

    for mask, mean_str in avg_pattern.findall(output_text):
        col = tag_to_col.get(mask)
        if col is not None:
            vals[col] = float(mean_str)

    return (
        src if src else "",
        tgt if tgt else "",
        vals["h4m0"],
        vals["h3m1"],
        vals["h2m2"],
        vals["h1m3"],
        vals["h0m4"],
    )


# ---------- experiment runner ----------

def run_experiment_and_store(n_value: int):
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

    # 새 포맷으로 파싱
    src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4 = parse_output(out)

    # DB에 기록
    insert_record(src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4)

    print(
        f"[+] Inserted: src={src}, tgt={tgt}, "
        f"h4m0={h4m0}, h3m1={h3m1}, h2m2={h2m2}, h1m3={h1m3}, h0m4={h0m4}"
    )

    return src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4


# ---------- main ----------

def main():
    create_db()

    # 예시: 한 번만 돌릴 때
    # 1: ~857575
    # 2: ~626871
    # 3: ~241777

    for i in range(0, 20):
        for n in range(0, 100):
            try:
                run_experiment_and_store(n)
            except Exception as e:
                print(f"[!] Experiment for NOP_REPEAT({n}) failed: {e}", file=sys.stderr)
                continue


if __name__ == "__main__":
    main()
