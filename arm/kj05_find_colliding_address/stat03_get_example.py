#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import argparse

# 1. 조건을 만족하는 (b1a, b2a) 쌍 중 하나 pick
SQL_PICK_ONE_PAIR = """
WITH stats AS (
    SELECT
        b1a,
        b2a,
        COUNT(*) AS total_count,
        SUM(CASE WHEN (miss - hit) > ? THEN 1 ELSE 0 END) AS filtered_count
    FROM res
    GROUP BY b1a, b2a
    HAVING total_count >= ?
       AND filtered_count >= 1
    ORDER BY filtered_count DESC, total_count DESC
    LIMIT 1
)
SELECT b1a, b2a, total_count, filtered_count FROM stats;
"""

# 2. 해당 쌍의 모든 행 출력 (threshold 상관 없음)
SQL_SELECT_PAIR_ROWS = """
SELECT
    printf('0x%08x', b1a) AS b1a_hex,
    printf('0x%08x', b2a) AS b2a_hex,
    hit,
    miss
FROM res
WHERE b1a = ? AND b2a = ?
ORDER BY (miss - hit) DESC;
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--threshold", type=float, required=True, help="(miss - hit) threshold")
    ap.add_argument("--min-count", type=int, default=5, help="minimum occurrences of (b1a,b2a) pair")
    ap.add_argument("--db", default="res.db", help="SQLite DB path")
    args = ap.parse_args()

    conn = sqlite3.connect(args.db)
    cur = conn.cursor()

    # Step 1: pick one (b1a,b2a) pair meeting the condition
    cur.execute(SQL_PICK_ONE_PAIR, (args.threshold, args.min_count))
    pair = cur.fetchone()
    if not pair:
        print(f"[!] No (b1a,b2a) pair found with total_count >= {args.min_count} and at least one row exceeding threshold {args.threshold}")
        conn.close()
        return

    b1a_val, b2a_val, total_count, filtered_count = pair
    print(f"[*] Selected pair: b1a=0x{b1a_val:08x}, b2a=0x{b2a_val:08x}")
    print(f"    total_count={total_count}, filtered_count={filtered_count} (miss - hit > {args.threshold})")

    # Step 2: fetch all rows for that pair (no threshold)
    cur.execute(SQL_SELECT_PAIR_ROWS, (b1a_val, b2a_val))
    rows = cur.fetchall()
    conn.close()

    print(f"[*] Printing all {len(rows)} rows for the selected pair:")
    print(f"{'b1a':>12}  {'b2a':>12}  {'hit':>12}  {'miss':>12}")
    print("-" * 52)
    for b1a_hex, b2a_hex, hit, miss in rows:
        print(f"{b1a_hex:>12}  {b2a_hex:>12}  {hit:12.6f}  {miss:12.6f}")

if __name__ == "__main__":
    main()
