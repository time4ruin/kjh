#include <unistd.h>

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

// memory load
#define memory_access(x) __asm__ volatile("LDR x10, [%[addr]]" :: [addr] "r" (x) : "x10", "memory")

void set_ghr();

uint64_t branch1(int input);
uint64_t branch2(int input);

void attacker();
void victim();

void delay(const uint64_t limit);
void sleep_nanos(uint64_t nanoseconds);