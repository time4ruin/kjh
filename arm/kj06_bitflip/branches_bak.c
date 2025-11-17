#include <time.h>
#include "common.h"

// 안정적 배치를 위해 inline/clone 방지 + 최적화 최소화
#define ATTR __attribute__((noinline, noclone, optimize("O0")))
#define NOP_REPEAT(n) __asm__ __volatile__ (".rept " #n "\n\t" "nop\n\t" ".endr\n\t")

ATTR
uint64_t branch1(int input)
{
    struct timespec begin, end;
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");

    __asm__ volatile (
        ".global branch1_eq_label  \n\t"
        "cmp    %w[input], #0      \n\t"
        "branch1_eq_label:         \n\t"
        "b.eq   branch1_else       \n\t"
        "branch1_if:               \n\t"
        ".rept 8000                \n\t"
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch1_end         \n\t"
        "branch1_else:             \n\t"
        ".rept 8000                \n\t"
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

// === branch1 과 branch2 사이의 큰 패드 ===
void dummy(void)
{
    /* PAD20 start */
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(8000);
	NOP_REPEAT(5900);
	/* PAD20 end */
}

ATTR
uint64_t branch2(int input)
{
    // === branch2 시작 직후의 미세 패드 (최대 10개만 사용) ===
    /* PADFINE_ENTRY start */
	/* PADFINE_ENTRY end */

    struct timespec begin, end;
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    clock_gettime(CLOCK_MONOTONIC, &begin);
    __asm__ volatile ("isb" ::: "memory");

    __asm__ volatile (
        ".global branch2_eq_label  \n\t"
        "cmp    %w[input], #0      \n\t"
        "branch2_eq_label:         \n\t"
        "b.eq   branch2_else       \n\t"
        "branch2_if:               \n\t"
        ".rept 8000                \n\t"
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch2_end         \n\t"
        "branch2_else:             \n\t"
        ".rept 8000                \n\t"
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
