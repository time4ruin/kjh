#include <time.h>
#include <stdio.h>

#include "common.h"

uint64_t branch1(int input)
{
	struct timespec begin, end;
    __asm__ volatile ("mfence" ::: "memory");
    __asm__ volatile ("lfence" ::: "memory");
    unsigned long long start_tsc, end_tsc; unsigned int __eax, __edx;
    __asm__ volatile ("cpuid\n\trdtsc\n\t" : "=a"(__eax), "=d"(__edx) : : "rbx","rcx");
    start_tsc = ((unsigned long long)__edx << 32) | __eax;
    __asm__ volatile ("lfence" ::: "memory");

    // === 여기 사이가 측정 구간 ===
    __asm__ volatile (
        ".global branch1_eq_label\n\t"
        "branch1_eq_label:\n\t"
        "cmpl $0, %[input]\n\t"
        "je branch1_end\n\t" /* input == 0 -> skip */

        "branch1_if:\n\t"
        ".rept 1\n\t"
        "nop\n\t"
        ".endr\n\t"

        "branch1_end:\n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    // ============================

    __asm__ volatile ("mfence" ::: "memory");
    __asm__ volatile ("rdtscp" : "=a"(__eax), "=d"(__edx) : : "rcx");
    end_tsc = ((unsigned long long)__edx << 32) | __eax;
    __asm__ volatile ("cpuid" ::: "rax","rbx","rcx","rdx");
	uint64_t latency = end_tsc - start_tsc;
    return latency;
}

void dummy_001()
{
    asm volatile(".p2align   14\n\t");
    __asm__ __volatile__("nop");
}
void dummy_002()
{
    asm volatile(".p2align   14\n\t");
    __asm__ __volatile__("nop");
}

uint64_t branch2(int input)
{
	struct timespec begin, end;
    __asm__ volatile ("mfence" ::: "memory");
    __asm__ volatile ("lfence" ::: "memory");
    unsigned long long start_tsc, end_tsc; unsigned int __eax, __edx;
    __asm__ volatile ("cpuid\n\trdtsc\n\t" : "=a"(__eax), "=d"(__edx) : : "rbx","rcx");
    start_tsc = ((unsigned long long)__edx << 32) | __eax;
    __asm__ volatile ("lfence" ::: "memory");

    // === 여기 사이가 측정 구간 ===
    __asm__ volatile (
        ".global branch2_eq_label\n\t"
        "branch2_eq_label:\n\t"
        "cmpl $0, %[input]\n\t"
        "je branch2_end\n\t" /* input == 0 -> skip */

        "branch2_if:\n\t"
        ".rept 1\n\t"
        "nop\n\t"
        ".endr\n\t"

        "branch2_end:\n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    // ============================

    __asm__ volatile ("mfence" ::: "memory");
    __asm__ volatile ("rdtscp" : "=a"(__eax), "=d"(__edx) : : "rcx");
    end_tsc = ((unsigned long long)__edx << 32) | __eax;
    __asm__ volatile ("cpuid" ::: "rax","rbx","rcx","rdx");
	uint64_t latency = end_tsc - start_tsc;
    return latency;
}