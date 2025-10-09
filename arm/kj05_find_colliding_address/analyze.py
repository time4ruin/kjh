#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import argparse
from typing import List

DB_PATH = "res.db"

def int_to_bitvec(x: int, low_skip: int, bit_count: int) -> List[int]:
    x >>= low_skip
    return [(x >> i) & 1 for i in range(bit_count)]

# ---- GF(2) 선형대수 유틸리티 ----
def gf2_rref(M):
    if not M:
        return []
    A = [row[:] for row in M]
    n_rows, n_cols = len(A), len(A[0])
    r = c = 0
    while r < n_rows and c < n_cols:
        piv = None
        for i in range(r, n_rows):
            if A[i][c] == 1:
                piv = i
                break
        if piv is None:
            c += 1
            continue
        A[r], A[piv] = A[piv], A[r]
        for i in range(n_rows):
            if i != r and A[i][c] == 1:
                A[i] = [(a ^ b) for a, b in zip(A[i], A[r])]
        r += 1
        c += 1
    return A

def orthogonal_complement_basis(M, ncols):
    R = gf2_rref(M)
    pivot_col = set()
    for row in R:
        try:
            j = row.index(1)
        except ValueError:
            continue
        pivot_col.add(j)

    free_cols = [j for j in range(ncols) if j not in pivot_col]
    basis = []
    for f in free_cols:
        v = [0]*ncols
        v[f] = 1
        for row in R:
            if 1 not in row:
                continue
            p = row.index(1)
            if row[f] == 1:
                v[p] ^= 1
        basis.append(v)
    return basis

# ---- 메인 ----
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--threshold", type=float, required=True)
    ap.add_argument("--arch", type=str, default=None)
    ap.add_argument("--low-skip", type=int, default=6)
    ap.add_argument("--bits", type=int, default=20)
    args = ap.parse_args()

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    if args.arch:
        cur.execute("SELECT b1a, b2a FROM res WHERE (miss - hit) > ? AND arch = ?", 
                    (args.threshold, args.arch))
    else:
        cur.execute("SELECT b1a, b2a FROM res WHERE (miss - hit) > ?", 
                    (args.threshold,))
    pairs = cur.fetchall()
    conn.close()

    print(f"\n[+] Threshold = {args.threshold}")
    print(f"[+] Selected pairs = {len(pairs)} rows\n")

    if not pairs:
        print("No pairs above threshold.")
        return

    M = []
    for b1a, b2a in pairs:
        d = b1a ^ b2a
        vec = int_to_bitvec(d, args.low_skip, args.bits)
        if any(vec):
            M.append(vec)

    if not M:
        print("All XOR differences are zero in selected range.")
        return

    basis = orthogonal_complement_basis(M, args.bits)
    if not basis:
        print("No non-trivial orthogonal complement found.")
        return

    print(f"# Inferred index bit parities over bits [{args.low_skip}..{args.low_skip+args.bits-1}]")
    for k, v in enumerate(basis):
        bits = [i+args.low_skip for i,b in enumerate(v) if b]
        desc = " XOR ".join([f"bit{b}" for b in bits]) if bits else "constant 0"
        print(f"index_bit_{k}: {desc}")

if __name__ == "__main__":
    main()
