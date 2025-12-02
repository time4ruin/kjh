#include <time.h>

#include "common.h"

void dummy()
{
    /* NOP start */
	NOP_REPEAT(34);
	/* NOP end */
}

uint64_t branch1(int input)
{
	struct timespec begin, end;
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");

    __asm__ volatile (
        ".global branch1_eq_label  \n\t"
        ".global branch1_else      \n\t"
        "cmp    %w[input], #0      \n\t"   // input == 0 ?
        "branch1_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch1_else       \n\t"   // if == 0 -> jump to else
        "branch1_if:               \n\t"
        ".rept 8000                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch1_end         \n\t"   // 끝으로 점프
        "branch1_else:             \n\t"
        ".rept 8000                \n\t"   // else 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "branch1_end:              \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );

    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &end);
    __asm__ volatile ("isb" ::: "memory");
	uint64_t latency = (uint64_t)(end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
    return latency;
}

uint64_t branch2(int input)
{
	NOP_REPEAT(10);
	struct timespec begin, end;
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");

    __asm__ volatile (
        ".global branch2_eq_label  \n\t"
        "cmp    %w[input], #0      \n\t"   // input == 0 ?
        "branch2_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch2_else       \n\t"   // if == 0 -> jump to else
        "branch2_if:               \n\t"
        ".rept 8000                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch2_end         \n\t"   // 끝으로 점프
        "branch2_else:             \n\t"
        ".rept 8000                \n\t"   // else 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "branch2_end:              \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );

    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
	clock_gettime(CLOCK_MONOTONIC, &end);
    __asm__ volatile ("isb" ::: "memory");
	uint64_t latency = (uint64_t)(end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
    return latency;
}