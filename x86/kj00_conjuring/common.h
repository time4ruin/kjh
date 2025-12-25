#include <unistd.h>
#include <stdint.h>

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

// memory load
#define memory_access(x) __asm__ volatile("movq (%[addr]), %%rax" :: [addr] "r" (x) : "rax", "memory")

int b1();

void set_ghr();

uint64_t branch1(int input);
uint64_t branch2(int input);

void delay(const uint64_t limit);
void sleep_nanos(uint64_t nanoseconds);

void print_histogram(uint64_t *arr, int size, const char *label);

/* stats helpers */
double trimmed_mean(uint64_t *arr, size_t n, size_t trim);
double trimmed_stddev(uint64_t *arr, size_t n, size_t trim);