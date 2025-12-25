#include <unistd.h>
#include <stdint.h>

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

// memory load (x86-64)
// conservative load into rax to ensure the memory is actually read
#define memory_access(x) __asm__ volatile("movq (%[addr]), %%rax" :: [addr] "r" (x) : "rax", "memory")

// (Use inline cpuid+rdtsc at call sites to avoid call overhead)

#define ATTR __attribute__((noinline, noclone, optimize("O0")))
#define NOP_REPEAT(n) __asm__ __volatile__ (".rept " #n "\n\t" "nop\n\t" ".endr\n\t")

void set_ghr();

void delay(const uint64_t limit);

void print_histogram(uint64_t *arr, int size, const char *label);
double trimmed_mean(uint64_t *arr, size_t n, size_t trim);
double trimmed_stddev(uint64_t *arr, size_t n, size_t trim);