#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <sched.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

int tests()
{
    int testsize = 1000;
    uint64_t *h4m0 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *h3m1 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *h2m2 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *h1m3 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *h0m4 = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    
    uint64_t addr1, addr2, addr3;
    __asm__ volatile(
        "ldr    %0, =branch1_eq_label\n\t"   // 절대 주소 로드
        "ldr    %1, =branch2_eq_label\n\t"
        "ldr    %2, =branch1_else\n\t"
        : "=r"(addr1), "=r"(addr2), "=r"(addr3)
        :
        : 
    );
    printf("address of branch1(src): %p\n", (void*)addr1);
    printf("address of branch2(tgt): %p\n", (void*)addr3);
    // printf("address of branch2: %p\n", (void*)addr2);
    // printf("address of function2: %p\n", branch2);

    // sched_yield();
    for (int i = 0; i < testsize; i++)
    {
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        
        // set_ghr();
        // branch2(1);
        
        // set_ghr();
        h4m0[i] = branch1(0);
    }
    sched_yield();
    for (int i = 0; i < testsize; i++)
    {
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(1);    
        
        // set_ghr();
        // branch2(0);
        
        // set_ghr();
        h3m1[i] = branch1(0);
    }
    sched_yield();
    for (int i = 0; i < testsize; i++)
    {
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);    
        
        // set_ghr();
        // branch2(0);
        
        // set_ghr();
        h2m2[i] = branch1(0);
    }
    sched_yield();
    for (int i = 0; i < testsize; i++)
    {
        // set_ghr();
        branch1(0);
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);    
        
        // set_ghr();
        // branch2(0);
        
        // set_ghr();
        h1m3[i] = branch1(0);
    }
    sched_yield();
    for (int i = 0; i < testsize; i++)
    {
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);
        // set_ghr();
        branch1(1);    
        
        // set_ghr();
        // branch2(0);
        
        // set_ghr();
        h0m4[i] = branch1(0);
    }

    // print_histogram(h4m0, testsize, "0000 - 0");
    // print_histogram(h3m1, testsize, "0001 - 0");
    // print_histogram(h2m2, testsize, "0011 - 0");
    // print_histogram(h1m3, testsize, "0111 - 0");
    // print_histogram(h0m4, testsize, "1111 - 0");
    double mean40 = trimmed_mean(h4m0, 100, 0);
    double mean31 = trimmed_mean(h3m1, 100, 0);
    double mean22 = trimmed_mean(h2m2, 100, 0);
    double mean13 = trimmed_mean(h1m3, 100, 0);
    double mean04 = trimmed_mean(h0m4, 100, 0);
    double stddev40 = trimmed_stddev(h4m0, 100, 0);
    double stddev31 = trimmed_stddev(h3m1, 100, 0);
    double stddev22 = trimmed_stddev(h2m2, 100, 0);
    double stddev13 = trimmed_stddev(h1m3, 100, 0);
    double stddev04 = trimmed_stddev(h0m4, 100, 0);
    printf("average (0000-0): %.2f (%.2f)\n", mean40, stddev40);
    printf("average (0001-0): %.2f (%.2f)\n", mean31, stddev31);
    printf("average (0011-0): %.2f (%.2f)\n", mean22, stddev22);
    printf("average (0111-0): %.2f (%.2f)\n", mean13, stddev13);
    printf("average (1111-0): %.2f (%.2f)\n", mean04, stddev04);
    // printf("average (hit): %.2f (%.2f)\n", mean_h, stddev_h);
    // print0("average (miss): %.2f (%.2f)\n", mean_m, stddev_m);
    free(h4m0);
    free(h3m1);
    free(h2m2);
    free(h1m3);
    free(h0m4);
    return 0;
}

int main()
{
    tests();
    return 0;
}
