#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import matplotlib.pyplot as plt

# 파일명 설정
FILE_RESULTS = "run_specific_results.txt"
FILE_PLOT = "run_specific_plot.png"


# ---------------------------
#  Formatting Helpers
# ---------------------------

def pad_float(x):
    """소수점 둘째 자리까지 강제"""
    try:
        return f"{float(x):.2f}"
    except:
        return x

def pad_hex_da(x):
    """0x + 6자리 hex 형태로 패딩: 0x00abcd"""
    try:
        val = int(x, 16)
        return f"0x{val:06x}"
    except:
        return x


# ---------------------------
#  Step 1. Format TXT In-Place
# ---------------------------

def format_file():
    lines_out = []

    with open(FILE_RESULTS, "r") as f:
        for line in f:
            line = line.rstrip("\n")

            # header / blank → 그대로
            if not line or line.startswith("==="):
                lines_out.append(line)
                continue

            # b1=0x... b2=0x... da=0x... hit=... conj=... miss=...
            m = re.match(
                r"b1=(0x[0-9a-fA-F]+)\s+"
                r"b2=(0x[0-9a-fA-F]+)\s+"
                r"da=(0x[0-9a-fA-F]+)\s+"
                r"hit=([0-9.]+)\s+"
                r"conj=([0-9.]+)\s+"
                r"miss=([0-9.]+)",
                line
            )

            if not m:
                lines_out.append(line)
                continue

            b1, b2, da, hit, conj, miss = m.groups()

            da_fmt = pad_hex_da(da)
            hit_fmt = pad_float(hit)
            conj_fmt = pad_float(conj)
            miss_fmt = pad_float(miss)

            new_line = (
                f"b1={b1}  b2={b2}  da={da_fmt}  "
                f"hit={hit_fmt}  conj={conj_fmt}  miss={miss_fmt}"
            )
            lines_out.append(new_line)

    # 덮어쓰기
    with open(FILE_RESULTS, "w") as f:
        for L in lines_out:
            f.write(L + "\n")

    print(f"[+] formatted file updated: {FILE_RESULTS}")


# ---------------------------
#  Step 2. Scatter Plot (small points)
# ---------------------------

def plot_graph():
    hits = []
    conjs = []
    misses = []

    with open(FILE_RESULTS, "r") as f:
        for line in f:
            line = line.strip()
            if not line.startswith("b1="):
                continue

            m = re.search(r"hit=([0-9.]+)\s+conj=([0-9.]+)\s+miss=([0-9.]+)", line)
            if not m:
                continue

            hit, conj, miss = m.groups()
            hits.append(float(hit))
            conjs.append(float(conj))
            misses.append(float(miss))

    if not hits:
        print("[!] No valid data found for plotting.")
        return

    xs = list(range(1, len(hits) + 1))

    plt.figure(figsize=(14, 6))

    # 작은 점의 산점도
    plt.scatter(xs, hits, s=1, label="hit")      # s=10 → 아주 작은 점
    plt.scatter(xs, conjs, s=1, label="conj")
    plt.scatter(xs, misses, s=1, label="miss")

    plt.ylim(0, 3)
    plt.xlabel("Experiment Index")
    plt.ylabel("Value")
    plt.title("Hit / Conj / Miss Scatter Distribution")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()

    plt.savefig(FILE_PLOT, dpi=200)
    print(f"[+] saved scatter plot to {FILE_PLOT}")


# ---------------------------
#  Main
# ---------------------------

def main():
    format_file()
    plot_graph()

if __name__ == "__main__":
    main()
