#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

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
        // printf("[HIT]  Time (ns): %lu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++)
    {
        set_ghr();
        branch1(1);
        
        set_ghr();
        branch1(1);
        
        set_ghr();
        branch1(1);
        
        set_ghr();
        branch1(0);
        
        set_ghr();
        miss[i] = branch1(1);
        // printf("[MISS] Time (ns): %lu\n", miss[i]);
    }

    print_histogram(hit, testsize, "HIT");
    print_histogram(miss, testsize, "MISS");
    free(hit);
    free(miss);
    return 0;
}

int main()
{
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
        delay(1000000);
        victim();
    }
    else
    {
        // Parent = Attacker
        attacker();
    }

    return 0;
}
