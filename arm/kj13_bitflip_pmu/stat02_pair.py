#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
import argparse
from collections import Counter, defaultdict

SQL_PER_PAIR_TMPL = """
WITH per_pair AS (
  SELECT
    b1a, b2a,
    COUNT(*) AS x,
    SUM(CASE WHEN (miss - hit) > ? THEN 1 ELSE 0 END) AS y
  FROM res
  WHERE (miss - hit) IS NOT NULL
  {arch_clause}
  {setghr_clause}
  GROUP BY b1a, b2a
)
-- threshold를 한 번이라도 초과한 쌍만 포함
SELECT b1a, b2a, x, y FROM per_pair
WHERE y > 0
"""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="res.db")
    ap.add_argument("--threshold", type=float, required=True)
    ap.add_argument("--arch", required=True, help="architecture (e.g., Snapdragon865)")
    ap.add_argument("--setghr", required=True, help="setghr (e.g., 1)")
    args = ap.parse_args()

    conn = sqlite3.connect(args.db)
    cur = conn.cursor()

    arch_clause = "AND arch = ?"
    setghr_clause = "AND setghr = ?"

    sql = SQL_PER_PAIR_TMPL.format(
        arch_clause=arch_clause,
        setghr_clause=setghr_clause
    )
    params = (args.threshold, args.arch, args.setghr)

    cur.execute(sql, params)
    rows = cur.fetchall()
    conn.close()

    # (x, y)별로 주소쌍 묶기
    grouped = defaultdict(list)
    for b1a, b2a, x, y in rows:
        grouped[(x, y)].append((b1a, b2a))

    # x별 y분포 집계
    dist = defaultdict(Counter)
    for (_, _), (b1a, b2a, x, y) in zip(grouped.keys(), rows):
        dist[x][y] += 1
    for b1a, b2a, x, y in rows:
        dist[x][y] += 1

    if not dist:
        print(f"No (b1a,b2a) pairs found for arch={args.arch}, setghr={args.setghr} with threshold={args.threshold}.")
        return

    all_x = sorted(dist.keys())
    max_x = max(all_x)

    header = ["x"] + [f"y={i}" for i in range(1, max_x + 1)]
    print(f"[arch={args.arch}, setghr={args.setghr}, threshold={args.threshold}]")
    print(" | ".join(f"{h:>10}" for h in header))
    print("-" * (len(header) * 13))

    for x in all_x:
        line = [f"{x:>10}"]
        for y in range(1, max_x + 1):
            if y > x:
                line.append(f"{'':>10}")
            else:
                line.append(f"{dist[x].get(y, 0):>10d}")
        print(" | ".join(line))

    # 선택 기능
    print("\nEnter (x,y) to view corresponding (b1a,b2a) pairs, or press Enter to quit.")
    while True:
        user_in = input("Select x,y (e.g. 10,2): ").strip()
        if not user_in:
            print("Exiting.")
            break
        try:
            x_sel, y_sel = map(int, user_in.split(","))
        except ValueError:
            print("Invalid input format. Use 'x,y'.")
            continue

        key = (x_sel, y_sel)
        if key not in grouped:
            print(f"No pairs found for x={x_sel}, y={y_sel}.")
            continue

        pairs = grouped[key]
        print(f"\n(x={x_sel}, y={y_sel}) → {len(pairs)} pairs:")
        for b1a, b2a in pairs:
            print(f"  b1a=0x{b1a:016x}, b2a=0x{b2a:016x}")
        print()

if __name__ == "__main__":
    main()
