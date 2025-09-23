CC      = aarch64-linux-gnu-gcc
CFLAGS  = -O0 -march=armv8-a -static
LDFLAGS = -no-pie -static -lm

# 소스 파일
SRC_C = delay.c set_ghr.c utils.c
SRC_ALL = attacker.c victim.c $(SRC_C)

# branches.s가 있으면 그걸 쓰고, 없으면 branches.c를 쓴다
ifeq ($(wildcard branches.s),)
  BRANCHES_INPUT = branches.c
else
  BRANCHES_INPUT = branches.s
endif

.PHONY: all as clean

all: as attacker.bin victim.bin

# 1) branches.c → branches.s
as: branches.s

branches.s: branches.c
	$(CC) $(CFLAGS) -S -o $@ $<

# 2) attacker.c → attacker.bin
attacker.bin:
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ attacker.c $(SRC_C) $(BRANCHES_INPUT)

# 3) victim.c → victim.bin
victim.bin:
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ victim.c $(SRC_C) $(BRANCHES_INPUT)

clean:
	rm -f *.s *.bin
