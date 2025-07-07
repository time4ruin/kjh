import re

attacker = '''    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    f1(1); // attacker branch
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    latency = t2 - t1;
    lines[n][0] = t1;
    lines[n][1] = t2;
    lines[n][2] = t2 - t1;
    lines[n][3] = latency;
    n++;
'''

victim = '''    delay10K();
    f1(0); // victim branch
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
    lines[n++] = now;
'''

def generate(filename, code, n):
    with open(filename, "r") as f:
        content = f.read()

    pattern = re.compile(
        r'(/\* *Auto Generate Start *\*/)(.*?)(/\* *Auto Generate End *\*/)',
        re.DOTALL
    )

    # 중간 코드 교체
    replacement = r'\1\n' + code * n + r'\t\3'

    # 코드 치환
    new_content = re.sub(pattern, replacement, content)

    # 덮어쓰기
    with open(filename, 'w') as f:
        f.write(new_content)

if __name__ == "__main__":
    generate("attacker.c", attacker, 1)
    generate("victim.c", victim, 1)