#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

int tests()
{
    int testsize = 1000;
    uint64_t *h4m0 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *h3m1 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    
    uint64_t addr1, addr2;
    __asm__ volatile(
        "ldr    %0, =branch1_eq_label\n\t"   // 절대 주소 로드
        "ldr    %1, =branch2_eq_label\n\t"
        : "=r"(addr1), "=r"(addr2)
        :
        : 
    );
    printf("address of branch1: %p\n", (void*)addr1);
    printf("address of branch2: %p\n", (void*)addr2);
    // printf("address of function2: %p\n", branch2);

    for (int i = 0; i < testsize; i++)
    {
        branch1(0);
        branch1(0);
        branch1(0);
        branch1(0);

        h4m0[i] = branch1(0);
    }
        for (int i = 0; i < testsize; i++)
    {
        branch1(0);
        branch1(0);
        branch1(0);
        branch1(1);    
        
        h3m1[i] = branch1(0);
    }
    for (int i = 0; i < testsize; i++)
    {
        branch1(0);
        branch1(0);
        branch1(0);
        branch1(0);    
        
        branch2(1);
        
        miss[i] = branch1(0);
    }

    double mean40 = trimmed_mean(h4m0, testsize, 0);
    double mean31 = trimmed_mean(h3m1, testsize, 0);
    double mean_m = trimmed_mean(miss, testsize, 0);
    printf("average (0000-0): %.2f\n", mean40 );
    printf("average (0001-0): %.2f\n", mean31);
    printf("average (0000-b2-0): %.2f\n", mean_m);
    free(h4m0);
    free(h3m1);
    free(miss);
    return 0;
}

int main()
{
    tests();
    return 0;
}
