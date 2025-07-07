# Makefile

CC = clang
CFLAGS = -O0 -Wall
TARGET = test.bin
SRC = main.c victim.c attacker.c delay.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)
