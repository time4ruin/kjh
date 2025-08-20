#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <_types/_uint32_t.h>

#include "common.h"
#include "../utils.c"

void inner(int input)
{
    if (input)
    {
        __asm__ __volatile__(
            ".rept 8000\n\t"
            "nop\n\t"
            ".endr\n\t" :::);
    }
    else
    {
        __asm__ __volatile__(
            ".rept 8000\n\t"
            "nop\n\t"
            ".endr\n\t" :::);
    }
}

void outer(int input1, int input2, int flag)
{
    if (input1)
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
        (void)(flag && (delay(10000), 0));
        (void)(flag && (inner(input2), 0));
    }
    else
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
}

inline __attribute__((always_inline))
uint64_t
rdtsc()
{
    uint64_t ts;
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %0, S3_2_c15_c0_0" : "=r"(ts) : :);
    asm volatile("isb");
    return ts;
}

inline __attribute__((always_inline)) uint64_t probe(void *ptr)
{
    uint64_t start = rdtsc();
    memory_access(ptr);
    uint64_t end = rdtsc();
    return end - start;
}

// Note: must serialize with isb and dsb ish
inline __attribute__((always_inline)) void clflush(void *ptr)
{
    asm volatile("dc civac, %0" : : "r"(ptr) : "memory");
}

int tests()
{
    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);

    printf("address of branch 1: %p\n", branch1);
    printf("address of branch 2: %p\n", branch2);

    // conjuring test
    for (int i = 0; i < testsize; i++)
    {
        set_ghr();
        branch1(1);
        set_ghr();
        hit[i] = branch1(1);
        // printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++)
    {
        set_ghr();
        branch2(0);
        set_ghr();
        branch2(0);
        set_ghr();
        branch2(0);
        set_ghr();
        branch2(0);
        set_ghr();
        miss[i] = branch2(1);
        // printf("[MISS] Time (ns): %llu\n", miss[i]);
    }

    print_histogram(hit, testsize, "HIT");
    print_histogram(miss, testsize, "MISS");
    free(hit);
    free(miss);
    return 0;
}

int main()
{
    uint32_t CORE_ID = 4;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

    tests();
    asm volatile("isb");
    // branch1(1);
    // branch2(1);

    pid_t pid = fork();
    if (pid < 0)
    {
        perror("fork failed");
        exit(1);
    }
    else if (pid == 0)
    {
        // Child = Victim
        // CORE_ID = 7;
        delay(1000000);
        volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
        if (ret == -1)
        {
            printf("Error setting CPU core affinity. Please run as root\n");
            return EXIT_FAILURE;
        }
        // victim();
    }
    else
    {
        // Parent = Attacker
        // attacker();
    }

    return 0;
}
