#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import matplotlib.pyplot as plt
from collections import defaultdict

DB_FILE = "res.db"


# ==========================================================
#  공통 데이터 로딩
# ==========================================================

def load_rows_simple():
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    rows = cur.execute("""
        SELECT da, hit, miss 
        FROM res
        WHERE da IS NOT NULL AND hit >= 0 AND miss >= 0
    """).fetchall()
    conn.close()
    return rows


def load_rows_full():
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()
    rows = cur.execute("""
        SELECT da, b1a, b2a, hit, miss
        FROM res
        WHERE da IS NOT NULL AND b1a IS NOT NULL AND b2a IS NOT NULL
          AND hit >= 0 AND miss >= 0
    """).fetchall()
    conn.close()
    return rows


# ==========================================================
#  filtered da 계산 (기본 기능)
# ==========================================================

def get_valid_das(thresh=0.7):
    rows = load_rows_simple()
    total = defaultdict(int)
    good = defaultdict(int)

    for da, hit, miss in rows:
        diff = miss - hit
        total[da] += 1
        if diff > thresh:
            good[da] += 1

    valid = {
        da for da in total
        if total[da] == good[da]
    }

    print(f"[i] Distinct da = {len(total)}")
    print(f"[i] Filtered da (all miss-hit > {thresh}) = {len(valid)}")
    return valid, rows


# ==========================================================
#  1) 전체 그래프
# ==========================================================

def plot_all(out_file="da_vs_miss_minus_hit.png"):
    rows = load_rows_simple()
    xs, ys = [], []

    for da, hit, miss in rows:
        xs.append(da)
        ys.append(miss - hit)

    plt.figure(figsize=(14, 7))
    plt.scatter(xs, ys, s=5)
    plt.title("da vs (miss - hit)")
    plt.xlabel("da (b1 ^ b2)")
    plt.ylabel("miss - hit")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(out_file, dpi=200)
    print(f"[+] Saved ALL graph → {out_file}")


# ==========================================================
#  2) filtered 그래프
# ==========================================================

def plot_filtered(thresh=0.7, out_file="da_vs_miss_minus_hit_filtered.png"):
    valid, rows = get_valid_das(thresh)

    xs, ys = [], []
    for da, hit, miss in rows:
        if da in valid:
            xs.append(da)
            ys.append(miss - hit)

    plt.figure(figsize=(14, 7))
    plt.scatter(xs, ys, s=5)
    plt.title(f"da vs (miss - hit) [ALL diff > {thresh}]")
    plt.xlabel("da")
    plt.ylabel("miss - hit")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(out_file, dpi=200)

    print(f"[+] Saved FILTERED graph → {out_file}")


# ==========================================================
#  3) filtered da → b1,b2,hit,miss text dump
# ==========================================================

def dump_filtered_da(thresh=0.7, out_file="filtered_da_dump.txt"):
    valid, _ = get_valid_das(thresh)
    rows = load_rows_full()

    rows_sorted = sorted(rows, key=lambda x: x[0])

    with open(out_file, "w") as f:
        f.write(f"Filtered da dump (threshold={thresh})\n")
        f.write("=" * 60 + "\n\n")

        last_da = None
        for da, b1, b2, hit, miss in rows_sorted:
            if da not in valid:
                continue

            if da != last_da:
                f.write(f"da={hex(da)}\n")
                last_da = da

            f.write(
                f"  b1={hex(b1)}  b2={hex(b2)}  hit={hit:.4f}  miss={miss:.4f}\n"
            )

    print(f"[+] Dumped filtered da entries → {out_file}")


# ==========================================================
#  4) PHT indexing hash 역추론 (선형제약 기반)
# ==========================================================

def popcount(x: int): return x.bit_count()

def is_mask_valid(mask: int, da_list):
    for d in da_list:
        if popcount(mask & d) % 2 != 0:
            return False
    return True


def add_to_basis(basis, vec):
    v = vec
    for b in basis:
        if v.bit_length() == b.bit_length():
            v ^= b
    if v == 0:
        return False
    basis.append(v)
    basis.sort(key=lambda x: x.bit_length(), reverse=True)
    return True


def analyze_hash_from_filtered(thresh=0.7, bits=14, shift=2):
    valid, _ = get_valid_das(thresh)

    da_pc_list = list({
        (da >> shift) & ((1 << bits) - 1)
        for da in valid
        if ((da >> shift) & ((1 << bits) - 1)) != 0
    })

    print(f"[i] Unique da_pc count = {len(da_pc_list)}")

    basis = []
    for mask in range(1, 1 << bits):
        if is_mask_valid(mask, da_pc_list):
            if add_to_basis(basis, mask):
                print(f"[+] basis mask : 0x{mask:x}")

    print("\n=== Final GF(2) Basis ===")
    for b in basis:
        print(f"mask=0x{b:x}  bits={[i for i in range(bits) if (b>>i)&1]}")


# ==========================================================
#  실행 entrypoint
# ==========================================================

if __name__ == "__main__":
    # 원하는 부분만 켜서 실행하면 됨
    thresh=0.9
    # 1) 기본 그래프
    # plot_all()

    # 2) filtered 그래프
    plot_filtered(thresh=thresh)

    # 3) filtered da 상세 정보 텍스트 덤프
    dump_filtered_da(thresh=thresh)

    # 4) 해시 역추론
    # analyze_hash_from_filtered(thresh=thresh)
