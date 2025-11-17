#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PHT Index Bit Inference Tool
----------------------------
- Reads 'res.db' from current directory
- Selects rows where (miss - hit) > threshold AND arch = <arch> AND setghr = <setghr>
- Computes b1a ^ b2a bit patterns
- Finds correlated or XOR-related bit groups
- Infers likely PHT index composition

Usage:
    python3 infer_pht_bits.py --threshold 0.1 --arch cortex_a77 --setghr 0
"""

import sqlite3
import pandas as pd
import numpy as np
import sys
from itertools import combinations
import networkx as nx
import argparse

# --------------------------------------
# Step 1. Load data from res.db (filtered by arch, setghr)
# --------------------------------------
def load_filtered(threshold, arch, setghr, db_path="res.db"):
    conn = sqlite3.connect(db_path)
    df = pd.read_sql_query(
        """
        SELECT b1a, b2a, da, hit, miss, arch, setghr
        FROM res
        WHERE (miss - hit) > ?
          AND arch = ?
          AND setghr = ?
        """,
        conn,
        params=(threshold, arch, setghr),
    )
    conn.close()
    if df.empty:
        print(f"[!] No rows for arch={arch}, setghr={setghr} with (miss-hit) > {threshold}")
    else:
        print(f"[*] Loaded {len(df)} rows (arch={arch}, setghr={setghr}, threshold>{threshold})")
    return df

# --------------------------------------
# Step 2. Compute XOR bit patterns
# --------------------------------------
def get_bit_patterns(df, bitwidth=16):
    patterns = []
    for _, row in df.iterrows():
        diff = int(row["b1a"]) ^ int(row["b2a"])
        bits = [(diff >> i) & 1 for i in range(bitwidth)]
        patterns.append(bits)
    bit_df = pd.DataFrame(patterns, columns=[f"bit{i}" for i in range(bitwidth)])
    print(f"[*] Generated bit difference matrix ({len(bit_df)} x {bitwidth})")
    return bit_df

# --------------------------------------
# Step 3. Analyze bit correlations
# --------------------------------------
def bit_correlation(bit_df):
    corr = bit_df.corr().abs()
    print("[*] Bit correlation matrix computed")
    return corr

# --------------------------------------
# Step 4. Find XOR-like relations
# --------------------------------------
def xor_relation(bit_df, tolerance=0.1):
    n = bit_df.shape[1]
    relations = []
    for i, j in combinations(range(n), 2):
        xor_col = bit_df.iloc[:, i] ^ bit_df.iloc[:, j]
        ratio = xor_col.mean()  # proportion of 1s
        if ratio < tolerance or ratio > 1 - tolerance:
            relations.append((i, j, int(ratio > 0.5)))
    print(f"[*] Found {len(relations)} XOR-like relations (|ratio-0.5|>{0.5 - tolerance})")
    return relations

# --------------------------------------
# Step 5. Group bits using XOR graph
# --------------------------------------
def group_bits_by_xor(relations, bitwidth):
    G = nx.Graph()
    G.add_nodes_from(range(bitwidth))
    for i, j, _ in relations:
        G.add_edge(i, j)
    groups = list(nx.connected_components(G))
    return groups

# --------------------------------------
# Step 6. Display result
# --------------------------------------
def display_groups(groups):
    print("\n[+] Inferred PHT Index Bit Groups:")
    for g in sorted(groups, key=lambda x: max(x), reverse=True):
        if len(g) == 1:
            print(f"  bit{list(g)[0]}")
        else:
            bits = " XOR ".join([f"bit{i}" for i in sorted(g, reverse=True)])
            print(f"  {bits}")

# --------------------------------------
# Main
# --------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--threshold", type=float, required=True, help="(miss - hit) threshold (float)")
    ap.add_argument("--arch", required=True, help="arch value to filter rows")
    ap.add_argument("--setghr", required=True, help="setghr value to filter rows (TEXT)")
    ap.add_argument("--db", default="res.db", help="SQLite DB path (default: res.db)")
    args = ap.parse_args()

    df = load_filtered(args.threshold, args.arch, args.setghr, db_path=args.db)
    if df.empty:
        sys.exit(0)

    # infer bitwidth automatically (cap to [8, 32])
    max_val = max(df["b1a"].max(), df["b2a"].max())
    bitwidth = int(max_val).bit_length()
    if bitwidth < 8:
        bitwidth = 8
    elif bitwidth > 32:
        bitwidth = 32
    print(f"[*] Using bitwidth={bitwidth}")

    bit_df = get_bit_patterns(df, bitwidth)
    _ = bit_correlation(bit_df)  # computed but not printed by default
    xor_rel = xor_relation(bit_df)
    groups = group_bits_by_xor(xor_rel, bitwidth)
    display_groups(groups)

if __name__ == "__main__":
    main()
