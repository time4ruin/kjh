#include <time.h>

#include "common.h"

uint64_t branch1(int input)
{
	struct timespec begin, end;
    asm volatile(".p2align   14\n\t");
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");
    if (input)
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    else
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &end);
    __asm__ volatile ("isb" ::: "memory");
	uint64_t latency = (uint64_t)(end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
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
    asm volatile(".p2align   14\n\t");
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");
    if (input)
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    else
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &end);
    __asm__ volatile ("isb" ::: "memory");
	uint64_t latency = (uint64_t)(end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
    return latency;
}