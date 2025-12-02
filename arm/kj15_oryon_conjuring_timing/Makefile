CC      = aarch64-linux-gnu-gcc
CFLAGS  = -O0 -march=armv8-a -static
LDFLAGS = -no-pie -static
LDLIBS  = -lm
TARGET  = test.bin

SRC_ALL = main.c set_ghr.c branches.c utils.c

# branches.s가 있으면 그걸 쓰고, 없으면 branches.c를 쓴다
ifeq ($(wildcard branches.s),)
  BRANCHES_INPUT = branches.c
else
  BRANCHES_INPUT = branches.s
endif

# branches.c를 제외한 나머지 C들
SRC_C = $(filter-out branches.c,$(SRC_ALL))

.PHONY: all as bin clean

# all: as 후 bin (하지만 bin은 as에 의존하지 않음)
all: as bin

# 1) C → S (branches만)
as: branches.s

branches.s: branches.c
	$(CC) $(CFLAGS) -S -o $@ $<

# 2) C/S → 바이너리 (중간 .o 파일 생성 안 함)
bin:
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(SRC_C) $(BRANCHES_INPUT) $(LDLIBS)
	
clean:
	rm -f $(TARGET) branches.s *.txt
