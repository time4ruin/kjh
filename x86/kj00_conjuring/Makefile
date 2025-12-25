CC      = gcc
CFLAGS  = -O0
LDFLAGS = -no-pie -lm
TARGET  = test.bin

SRC_ALL = main.c delay.c set_ghr.c branches.c utils.c

# branches.s가 있으면 그걸 쓰고, 없으면 branches.c를 쓴다
ifeq ($(wildcard branches.s),)
  BRANCHES_INPUT = branches.c
else
  BRANCHES_INPUT = branches.s
endif

# branches.c를 제외한 나머지 C들
SRC_C = $(filter-out branches.c,$(SRC_ALL))

.PHONY: all as bin clean

# all: bin (as is optional)
all: bin

# 1) C → S (branches만)
as: branches.s

branches.s: branches.c
	$(CC) $(CFLAGS) -S -o $@ $<

# 2) C/S → 바이너리 (중간 .o 파일 생성 안 함)
bin:
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC_C) $(BRANCHES_INPUT) $(LDFLAGS)

clean:
	rm -f $(TARGET) branches.s *.txt
