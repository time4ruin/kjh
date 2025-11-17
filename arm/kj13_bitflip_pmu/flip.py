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
SETGHR = "0"

# 만들고 싶은 타겟 비트 범위 (k)
BIT_MIN = 3
BIT_MAX = 15

PADFINE1_MAX = 10   # branch1 앞 미세 패드
PADFINE2_MAX = 10   # branch2 앞 미세 패드
MAX_ITER = 30

LOCAL_BIN_DIR = Path("./out_bins")
SUMMARY_PATH = LOCAL_BIN_DIR / "summary.txt"

# branch1이 반드시 맞춰야 하는 절대 주소
TARGET_B1_ADDR_HEX = "0x402258"
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


def compute_target_mask_pair(k: int) -> int:
    """
    bit 25와 bit k, 두 개의 bit만 다르게 만들기 위한 XOR mask.
    """
    return (1 << 25) | (1 << k)


def target_b2(b1_hex: str, mask: int) -> int:
    return int(b1_hex, 16) ^ mask


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
                  save_copy_name: Optional[str] = None,
                  target_mask: Optional[int] = None
                  ) -> Tuple[str, str, str, Optional[float], Optional[float]]:
    """
    주어진 패딩 값으로 branches.c를 갱신 → 빌드 → 실행 → 주소/latency 파싱.
    target_bit/target_mask는 DB 기록용 메타데이터.
    """
    set_pads(pad1, padfine1, pad2, padfine2)
    build_binary()

    if save_copy_name:
        LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / save_copy_name)

    out = push_and_run_on_device(BIN_NAME)
    b1, b2, hit, miss = parse_output(out)
    da = hex_xor(b1, b2)

    if target_mask is not None:
        mask = target_mask
    elif target_bit is not None:
        mask = compute_target_mask(target_bit)
    else:
        mask = None

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


# ---------- Step1: branch1 주소를 정확히 0x402258로 맞추기 ----------
def solve_branch1_to_addr(target_addr_hex: str,
                          pad1_init: int = 0,
                          padfine1_init: int = 0
                          ) -> Tuple[int, int, str]:
    """
    branch1 주소를 target_addr_hex로 맞출 때까지
    PAD1/PADFINE1을 '앞으로만' 이동시키면서 정렬.
    - target_addr와 현재 b1이 4-byte aligned라고 가정.
    - 현재 b1 > target이면 더 이상 앞으로만 이동해서는 맞출 수 없으므로 실패.
    """
    target = int(target_addr_hex, 16)

    pad1 = max(0, int(pad1_init))
    padfine1 = max(0, int(padfine1_init))

    for _ in range(MAX_ITER):
        # PAD2/PADFINE2 = 0인 상태에서 현재 branch1 측정
        b1, _, _, _ = one_build_run(pad1, padfine1, 0, 0, None)[0:4]
        if not b1:
            raise RuntimeError("Failed to get branch1 address while aligning.")

        b1i = int(b1, 16)
        if b1i == target:
            print(f"[i] branch1 aligned at {b1} "
                  f"(PAD1={pad1}, F1={padfine1})")
            return pad1, padfine1, b1

        if b1i > target:
            raise RuntimeError(
                f"Cannot reach target {target_addr_hex}: "
                f"current b1={b1} already beyond target "
                f"(PAD1={pad1}, F1={padfine1})."
            )

        delta_bytes = target - b1i      # > 0
        add_nops = (delta_bytes + 3) // 4   # 필요 NOP 개수 (4B 단위)

        # padfine1(≤MAX) 우선, 나머지는 pad1에 추가
        room_f1 = PADFINE1_MAX - padfine1
        use_f1 = min(add_nops, room_f1)
        padfine1 += use_f1
        pad1 += (add_nops - use_f1)

        # 다음 루프에서 재측정

    raise RuntimeError(
        f"Alignment failed for target {target_addr_hex}: "
        f"not converged within {MAX_ITER} iterations."
    )


# ---------- Step2: da == (1<<25) | (1<<k) 만들기 ----------
def solve_for_bit_pair(k: int,
                       pad1: int,
                       padfine1: int
                       ) -> Optional[Tuple[int, int, int, int]]:
    """
    1) branch1 주소는 이미 solve_branch1_to_addr에 의해 TARGET_B1_ADDR_HEX로 고정되어 있다고 가정.
    2) PAD1/PADFINE1은 건드리지 않고, PAD2/PADFINE2만 조정하여
       da = b1 ^ b2 == (1<<25) | (1<<k) 를 만족시키는 레이아웃 탐색.
    성공 시 (pad1, padfine1, pad2, padfine2) 반환.
    """
    if k == 25:
        print(f"[!] k={k}: bit25와 같은 bit는 두 개의 bit 차이가 아니므로 건너뜀.")
        return None

    target_mask = compute_target_mask_pair(k)
    print(f"\n[>] Solve for 2-bit XOR: fixed_bit=25, k={k}, "
          f"target_mask={hex(target_mask)}")

    pad2 = 0
    padfine2 = 0

    b1, b2, da, *_ = one_build_run(
        pad1, padfine1, pad2, padfine2,
        target_bit=k,
        target_mask=target_mask
    )
    if not (b1 and b2):
        print("[!] Initial measurement failed (missing addresses).")
        return None

    # branch1이 원하는 절대 주소인지 체크 (debug용)
    if int(b1, 16) != int(TARGET_B1_ADDR_HEX, 16):
        print(f"[!] Warning: b1={b1} != {TARGET_B1_ADDR_HEX}")

    for _ in range(MAX_ITER):
        if not (b1 and b2 and da):
            break

        b1_val = int(b1, 16)
        b2_val = int(b2, 16)
        da_val = int(da, 16)

        if da_val == target_mask:
            # 성공
            final_name = f"test.bit25_{k}.bin"
            shutil.copyfile(BIN_NAME, LOCAL_BIN_DIR / final_name)
            _add_summary_row(
                final_name, b1, b2, target_mask,
                pad1, padfine1, pad2, padfine2
            )
            print(f"[✓] bit pair (25,{k}): SOLVED with "
                  f"PAD1={pad1}, F1={padfine1}, PAD2={pad2}, F2={padfine2}")
            return pad1, padfine1, pad2, padfine2

        target_b2_val = target_b2(b1, target_mask)
        delta_bytes = target_b2_val - b2_val

        if delta_bytes == 0:
            # XOR 불일치는 다른 비트 영향일 수 있으니 미세 이동
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
        else:  # delta_bytes < 0 → 현재 b2가 target_b2보다 앞서 있음(뒤로 가야 함)
            step_nops = max(1, (abs(delta_bytes) // 4))
            if pad2 >= step_nops:
                pad2 -= step_nops
            else:
                pad2 = 0
                # PAD2=0에서도 이미 target보다 큰 경우 → branch1을 더 밀지 않고는 불가. 실패 처리.
                print(f"[!] bit pair (25,{k}): target_b2 < current b2 "
                      f"even with PAD2=0. Give up for this k.")
                break

        # 업데이트 후 재측정
        b1, b2, da, *_ = one_build_run(
            pad1, padfine1, pad2, padfine2,
            target_bit=k,
            target_mask=target_mask
        )

    print(f"[x] bit pair (25,{k}): failed to solve within {MAX_ITER} iterations.")
    return None


# ---------- main ----------
def main():
    create_db()
    LOCAL_BIN_DIR.mkdir(parents=True, exist_ok=True)

    # Baseline 저장 (참고용)
    print("[+] Baseline")
    b1, b2, da, *_ = one_build_run(
        0, 0, 0, 0, None,
        save_copy_name="test.baseline.bin"
    )
    if not (b1 and b2):
        print("[!] Baseline failed: missing addresses")
        sys.exit(1)
    print(f"[i] baseline: b1={b1}, b2={b2}, da={da}")

    # Step1: branch1을 TARGET_B1_ADDR_HEX로 정렬
    print(f"\n[+] Align branch1 to {TARGET_B1_ADDR_HEX}")
    pad1_state, padfine1_state, b1_fixed = solve_branch1_to_addr(
        TARGET_B1_ADDR_HEX, 0, 0
    )
    print(f"[i] fixed branch1: {b1_fixed} "
          f"(PAD1={pad1_state}, F1={padfine1_state})")

    # Step2: 각 k에 대해 (25, k) 두 bit만 다른 XOR mask 만들기
    for k in range(BIT_MIN, BIT_MAX + 1):
        if k == 25:
            continue
        solve_for_bit_pair(k, pad1_state, padfine1_state)
        # branch1 주소는 항상 0x402258이어야 하므로 pad1_state/padfine1_state는 업데이트하지 않음

    _write_summary_file()


if __name__ == "__main__":
    main()
