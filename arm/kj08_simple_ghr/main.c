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
    int testsize = 100;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
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
    printf("address of function2: %p\n", branch2);

    for (int i = 0; i < testsize; i++)
    {
        set_ghr(0x0fff);
        branch1(1);
        set_ghr(0xf0ff);
        branch1(1);
        set_ghr(0xff0f);
        branch1(1);
        set_ghr(0xfff0);
        branch1(1);
        
        set_ghr(0xffff);
        hit[i] = branch1(1);
        // printf("[HIT]  Time (ns): %lu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++)
    {
        set_ghr(0x0fff);
        branch1(1);   
        set_ghr(0xf0ff);
        branch1(1);   
        set_ghr(0xff0f);
        branch1(1);   
        set_ghr(0xfff0);
        branch1(0);
        
        set_ghr(0xffff);
        miss[i] = branch1(1);
        // printf("[MISS] Time (ns): %lu\n", miss[i]);
    }

    // print_histogram(hit, testsize, "HIT");
    // print_histogram(miss, testsize, "MISS");
    double mean_h = trimmed_mean(hit, 100, 20);
    double mean_m = trimmed_mean(miss, 100, 20);
    printf("average (hit): %.2f\n", mean_h);
    printf("average (miss): %.2f\n", mean_m);
    free(hit);
    free(miss);
    return 0;
}

int main()
{
    tests();
    return 0;
}
