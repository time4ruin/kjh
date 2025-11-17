#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sqlite3
from pathlib import Path
from collections import defaultdict

import numpy as np
import matplotlib.pyplot as plt

DB_FILE = Path("res_b1.db")
PLOT_DIR = Path("plot")

# DB 컬럼 순서 (값 읽을 때 사용)
COL_NAMES = ["h4m0", "h3m1", "h2m2", "h1m3", "h0m4"]

# x축에 표시할 레이블 (mask 형식)
X_LABELS = ["0000-0", "0001-0", "0011-0", "0111-0", "1111-0"]

# y축 경계 실제 값 (설명용 / 라벨용)
Y_BOUND_LABELS = ["0", "1.0", "1.2", "1.4", "1.6", "1.8", "2.0"]


def value_to_bin_index(v: float) -> int:
    """
    값 v를 7개 구간 중 어느 구간에 넣을지 결정.
    구간:
      0: 0   <= v < 1
      1: 1   <= v < 1.2
      2: 1.2 <= v < 1.4
      3: 1.4 <= v < 1.6
      4: 1.6 <= v < 1.8
      5: 1.8 <= v < 2.0
      6: 2.0 <= v       (2 이상)
    """
    if v < 1.0:
        return 0
    elif v < 1.2:
        return 1
    elif v < 1.4:
        return 2
    elif v < 1.6:
        return 3
    elif v < 1.8:
        return 4
    elif v < 2.0:
        return 5
    else:
        return 6


def load_data(db_path: Path):
    """
    res_b1.db에서 src, tgt, h4m0~h0m4를 읽어서
    src별로 묶어서 리턴한다.

    return:
      src_to_rows: dict[src_int] = list of (tgt_int, [h4m0..h0m4])
    """
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    cur.execute("SELECT src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4 FROM res")

    src_to_rows = defaultdict(list)

    for row in cur.fetchall():
        src, tgt, h4m0, h3m1, h2m2, h1m3, h0m4 = row
        if src is None or tgt is None:
            continue
        vals = [h4m0, h3m1, h2m2, h1m3, h0m4]
        src_to_rows[src].append((tgt, vals))

    conn.close()
    return src_to_rows


def make_heatmap_for_src(src: int, rows, out_dir: Path):
    """
    주어진 src에 대해 rows( (tgt, [h4m0..h0m4]) 들 )를 사용해
    7x5 heatmap을 만들고 PNG로 저장.
    - x축: 0000-0, 0001-0, 0011-0, 0111-0, 1111-0
    - y축: 7개 bin (0~1, 1~1.2, ..., 2~) 모두 같은 높이
    - 색: 해당 src에 대한 count 분포 (0=흰색, max=검정)
    """
    # rows: list of (tgt_int, [h4m0..h0m4])
    # 제목에 쓸 대표 tgt는 첫 번째 행의 tgt 사용
    first_tgt = rows[0][0]

    # 7 x 5 counts
    counts = np.zeros((7, len(COL_NAMES)), dtype=int)
    for tgt, vals in rows:
        for j, v in enumerate(vals):
            if v is None:
                continue
            idx = value_to_bin_index(v)
            counts[idx, j] += 1

    # 색 스케일: 0 ~ (해당 src에서의 최대 count)
    max_count = int(counts.max())
    if max_count <= 0:
        max_count = 1  # all zero인 경우 대비

    # y=0~7, x=0~5 (균일 높이/폭)
    y_edges = np.arange(8)  # row 경계: 0,1,2,3,4,5,6,7
    x_edges = np.arange(len(COL_NAMES) + 1)  # 0..5

    fig, ax = plt.subplots(figsize=(6, 5))

    pcm = ax.pcolormesh(
        x_edges,
        y_edges,
        counts,
        cmap="gray_r",     # 0=white, max_count=black
        vmin=0,
        vmax=max_count,
        shading="flat",
    )

    # x축: 각 칸 중앙에 틱 & 레이블
    x_centers = np.arange(len(COL_NAMES)) + 0.5
    ax.set_xticks(x_centers)
    ax.set_xticklabels(X_LABELS)

    # y축: 0~6 위치에 tick, 라벨은 실제 경계값(0,1,1.2,...,2)
    ax.set_yticks(np.arange(7))
    ax.set_yticklabels(Y_BOUND_LABELS)
    ax.set_ylabel("average value (bin boundaries)")

    # 타이틀: src - tgt (hex 표기)
    src_hex = f"0x{src:x}"
    tgt_hex = f"0x{first_tgt:x}"
    ax.set_title(f"{src_hex} - {tgt_hex}")

    # colorbar: count (0~max_count)
    cbar = fig.colorbar(pcm, ax=ax)
    cbar.set_label(f"Count (0 ~ {max_count})")

    plt.tight_layout()

    out_dir.mkdir(exist_ok=True, parents=True)
    filename = out_dir / f"src_{src_hex[2:]}_tgt_{tgt_hex[2:]}.png"
    plt.savefig(filename, dpi=150)
    plt.close(fig)

    print(f"[+] Saved: {filename} (max_count={max_count})")


def main():
    if not DB_FILE.exists():
        print(f"[!] DB file not found: {DB_FILE}")
        return

    src_to_rows = load_data(DB_FILE)
    print(f"[+] Loaded {len(src_to_rows)} distinct src values")

    for src in sorted(src_to_rows.keys()):
        rows = src_to_rows[src]
        make_heatmap_for_src(src, rows, PLOT_DIR)


if __name__ == "__main__":
    main()
