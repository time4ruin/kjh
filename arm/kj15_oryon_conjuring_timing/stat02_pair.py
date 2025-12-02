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
SELECT x, y FROM per_pair
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

    # arch, setghr 절 (무조건 존재하므로 AND 붙여도 됨)
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

    # x별 y값 집계
    dist = defaultdict(Counter)
    for x, y in rows:
        dist[x][y] += 1

    if not dist:
        print(f"No (b1a,b2a) pairs found for arch={args.arch}, setghr={args.setghr} with threshold={args.threshold}.")
        return

    all_x = sorted(dist.keys())
    max_x = max(all_x)

    # 헤더: y=1 .. max_x (y=0 제거)
    header = ["x"] + [f"y={i}" for i in range(1, max_x + 1)]
    print(f"[arch={args.arch}, setghr={args.setghr}, threshold={args.threshold}]")
    print(" | ".join(f"{h:>10}" for h in header))
    print("-" * (len(header) * 13))

    for x in all_x:
        line = [f"{x:>10}"]
        for y in range(1, max_x + 1):
            if y > x:
                line.append(f"{'':>10}")  # 불가능한 칸은 공백
            else:
                line.append(f"{dist[x].get(y, 0):>10d}")
        print(" | ".join(line))

if __name__ == "__main__":
    main()
