#define _GNU_SOURCE
#include <linux/perf_event.h>
#include <asm/unistd.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "common.h"

void dummy1(void)
{
    /* PAD1 start */
    NOP_REPEAT(7970);
/* PAD1 end */
}

ATTR
uint64_t outer(int input)
{
    /* PADFINE1 start */
    NOP_REPEAT(10);
/* PADFINE1 end */

    uint64_t t1, t2, t;

    asm volatile("mfence" ::: "memory");
    {
        unsigned int lo, hi;
        __asm__ volatile(
            "cpuid\n\t" /* serialize */
            "rdtsc\n\t"
            : "=a"(lo), "=d"(hi)
            : "a"(0)
            : "rbx", "rcx");
        t1 = ((uint64_t)hi << 32) | lo;
    }
    asm volatile("mfence" ::: "memory");

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

    asm volatile("mfence" ::: "memory");
    {
        unsigned int lo, hi;
        __asm__ volatile(
            "rdtscp\n\t"
            : "=a"(lo), "=d"(hi)
            :
            : "rcx");
        t2 = ((uint64_t)hi << 32) | lo;
    }
    __asm__ volatile ("cpuid" ::: "rax","rbx","rcx","rdx");
    asm volatile("mfence" ::: "memory");

    return t2 - t1;
}

void dummy2()
{
    /* PAD2 start */
    NOP_REPEAT(8000);
    NOP_REPEAT(8000);
    NOP_REPEAT(8000);
    NOP_REPEAT(7875);
/* PAD2 end */
}

// func() 실행 시 걸린 유저 모드 cpu_cycles만 리턴
ATTR
uint64_t inner(int input)
{
    /* PADFINE2 start */
    NOP_REPEAT(10);
/* PADFINE2 end */

    uint64_t t1, t2, t;

    asm volatile("mfence" ::: "memory");
    {
        unsigned int lo, hi;
        __asm__ volatile(
            "cpuid\n\t" /* serialize */
            "rdtsc\n\t"
            : "=a"(lo), "=d"(hi)
            : "a"(0)
            : "rbx", "rcx");
        t1 = ((uint64_t)hi << 32) | lo;
    }
    asm volatile("mfence" ::: "memory");

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

    asm volatile("mfence" ::: "memory");
    {
        unsigned int lo, hi;
        __asm__ volatile(
            "rdtscp\n\t"
            : "=a"(lo), "=d"(hi)
            :
            : "rcx");
        t2 = ((uint64_t)hi << 32) | lo;
    }
    __asm__ volatile ("cpuid" ::: "rax","rbx","rcx","rdx");
    asm volatile("mfence" ::: "memory");

    return t2 - t1;
}

void initialize_branch_predictor()
{
    /* Call the branch function multiple times to initialize the predictor */
    for (int i = 0; i < 1000; i++) {
        inner(1); 
        inner(0); 
        outer(1);
        outer(0);
    }
}

int main(){
    initialize_branch_predictor();

    uint64_t addr1, addr2;
    __asm__ volatile(
        "leaq branch1_eq_label(%%rip), %0\n\t"   // 절대 주소 로드
        "leaq branch2_eq_label(%%rip), %1\n\t"
        : "=r"(addr1), "=r"(addr2)
        :
        : 
    );
    printf("[ATK] address of outer branch: %p\n", (void*)addr1);
    printf("[ATK] address of inner branch: %p\n", (void*)addr2);
    fflush(stdout);

    uint64_t (*lines)[4] = malloc(sizeof(uint64_t[MAX_LINES][4]));
    if (!lines) {
        perror("malloc failed");
        return 0;
    }

    struct timespec ts, t1, t2;
    int n = 0;

    FILE *fp = fopen("p2.txt", "w");

    /* branchless */
    uint64_t counter = 0;
    uint64_t limit = 100000;
    uint64_t br_mis_pred, now;

    // 종료 조건이 명시적 branch 없이 평가되도록 만듦
    while (1) {
        delay(100000);

        br_mis_pred = inner(0); // attacker branch
        
        __asm__ volatile ("mfence" ::: "memory");
        __asm__ volatile ("lfence" ::: "memory");        
        {
            unsigned int lo, hi;
            __asm__ volatile(
                "rdtscp\n\t"
                : "=a"(lo), "=d"(hi)
                :
                : "rcx");
            now = ((uint64_t)hi << 32) | lo;
        }
        __asm__ volatile ("cpuid" ::: "rax","rbx","rcx","rdx");
        __asm__ volatile ("lfence" ::: "memory");
        lines[n][0] = now;
        lines[n][1] = br_mis_pred;
        n++;

        // 탈출 처리
        uint64_t diff = counter - limit;
        uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

        // 종료 처리 - branch 없이 loop 탈출
        // 방법: break_mask를 포인터에 곱해서 null이면 no-op, 아니면 break
        void* targets[] = {&&break_loop, &&continue_loop};
        goto *targets[continue_mask];

continue_loop:
        counter++;
    }

break_loop:
    printf("Loop ended at counter = %lu\n", counter);

    for (int i = 0; i < n; ++i) {
        fprintf(fp, "%lu, %lu\n", lines[i][0], lines[i][1]);
    }
    /* branchless */

    fclose(fp);
    free(lines);
    printf("Attacker(Parent) End\n");

    return 0;
}