#include <unistd.h>
#include <stdint.h>

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

// memory load
#define memory_access(x) __asm__ volatile("LDR x10, [%[addr]]" :: [addr] "r" (x) : "x10", "memory")

#define ATTR __attribute__((noinline, noclone, optimize("O0")))
#define NOP_REPEAT(n) __asm__ __volatile__ (".rept " #n "\n\t" "nop\n\t" ".endr\n\t")

int b1();

void set_ghr();

uint64_t branch1(int input);
uint64_t branch2(int input);

void print_histogram(uint64_t *arr, int size, const char *label);
double trimmed_mean(uint64_t *arr, size_t n, size_t trim);
double trimmed_stddev(uint64_t *arr, size_t n, size_t trim);