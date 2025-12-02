CC      = aarch64-linux-gnu-gcc
CFLAGS  = -O0 -march=armv8-a -static
LDFLAGS = -no-pie -static
LDLIBS  = -lm

# 공통 소스 (main.c, attacker.c, victim.c는 제외)
COMMON_SRCS = delay.c set_ghr.c utils.c

.PHONY: all as attacker victim clean

all: as attacker victim

# 1) C → S
as: attacker.s victim.s

attacker.s: attacker.c
	$(CC) $(CFLAGS) -S -o $@ $<

victim.s: victim.c
	$(CC) $(CFLAGS) -S -o $@ $<

# 2) attacker.bin
attacker: attacker.bin

attacker.bin: attacker.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ attacker.c $(COMMON_SRCS) $(LDLIBS)

# 3) victim.bin
victim: victim.bin

victim.bin: victim.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ victim.c $(COMMON_SRCS) $(LDLIBS)

clean:
	rm -f attacker.bin victim.bin *.s *.txt
