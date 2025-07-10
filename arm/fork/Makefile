# Makefile

# Variables
TARGET = test.bin
SRC = main.c attacker.c victim.c
OBJ = $(SRC:.c=.o)
ASM = $(SRC:.c=.s)
CC = aarch64-linux-gnu-gcc
CFLAGS = -O0 -march=armv8-a -static
LDFLAGS = -no-pie -static -lm

# Default target
all: $(TARGET)

# Build each .o from .c
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Build each .s from .c
%.s: %.c
	$(CC) $(CFLAGS) -S $< -o $@

# Link all objects to final binary
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

# Clean
clean:
	rm -f $(TARGET) $(OBJ) $(ASM)

single_test:
	aarch64-linux-gnu-gcc -O2 -static -o single_test.bin single_test.c -lm
