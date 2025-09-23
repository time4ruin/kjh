# generate_rand.py (Apple M1 / AArch64)
import random
import sys
import subprocess
import os
import io

def generate(branch_count=10000, out_c="set_ghr.c"):
    random.seed()
    s = io.StringIO()

    s.write("void set_ghr(void){\n")
    s.write("\t__asm__ __volatile__(\n")
    # Z=1로 고정 (xzr 비교 → 레지스터 영향 없음)
    s.write('\t\t"cmp xzr, xzr\\n\\t"\\\n')

    for i in range(branch_count):
        # label = f"pht{i}"
        label = f"Lpht{i}_%="      # 또는 ".Lpht{i}_%="
        r = random.randint(0, 3)
        # AArch64용: 로컬 + 유니크 라벨 생성

        if r == 0:
            s.write(f'\t\t"b.eq {label}\\n\\t"\n')
            s.write(f'\t\t"nop\\n\\t"\n')
            s.write(f'\t\t"{label}:\\n\\t"\n')
        elif r == 1:
            s.write(f'\t\t"b.eq {label}\\n\\t"\n')
            s.write(f'\t\t"{label}:\\n\\t"\n')
        elif r == 2:
            s.write(f'\t\t"b.ne {label}\\n\\t"\n')
            s.write(f'\t\t"{label}:\\n\\t"\n')
        else:
            s.write(f'\t\t"b.ne {label}\\n\\t"\n')
            s.write(f'\t\t"nop\\n\\t"\n')
            s.write(f'\t\t"{label}:\\n\\t"\n')


    s.write('\t\t"nop\\n"\n')
    # 클러버에 cc만 선언 (레지스터는 건드리지 않음)
    s.write('\t\t:\n\t\t:\n\t\t: "cc");\n')
    s.write("}\n")

    with open(out_c, "w") as f:
        f.write(s.getvalue())

if __name__ == "__main__":
    print("Generating random PRC...")
    generate()
