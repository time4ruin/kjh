# ===============================================
# Makefile for ARMv8 PMU test (perf_event_open)
# Target: Snapdragon / ARM64 (Android)
# Build-only version (no adb)
# ===============================================

CC       = aarch64-linux-gnu-gcc
CFLAGS   = -O2 -static -Wall
LDFLAGS  = -static
SRC      = main.c
TARGET   = test.bin

# -----------------------------------------------
# 기본 빌드
# -----------------------------------------------
all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

# -----------------------------------------------
# 정리
# -----------------------------------------------
clean:
	rm -f $(TARGET)
	@echo "[✓] Cleaned build files"

# -----------------------------------------------
# 헬프
# -----------------------------------------------
help:
	@echo "Usage:"
	@echo "  make        - Build $(TARGET)"
	@echo "  make clean  - Remove build artifacts"
