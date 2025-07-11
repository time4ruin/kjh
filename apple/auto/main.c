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

void f1(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

void dummy(){
    __asm__ __volatile__(
    ".rept 7191\n\t"
    "nop\n\t"
    ".endr\n\t"
    :::);
}

void f2(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

int check_conjuring(){
    uint64_t t1, t2;
    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);

    for (int i = 0; i < testsize; i++) {
        f1(0);
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("isb");
        f1(0); // not-taken
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
        asm volatile("isb");
        hit[i] = t2 - t1;
        printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++) {
        f1(1);
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("isb");
        f1(0); // not-taken
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
        asm volatile("isb");
        miss[i] = t2 - t1;
        printf("[MISS] Time (ns): %llu\n", miss[i]);
    }

    print_histogram(hit, testsize, "HIT");
    print_histogram(miss, testsize, "MISS");
    free(hit);
    free(miss);
    return 0;
}

int main() {
    uint32_t CORE_ID = 3;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

    check_conjuring();

    // Test Delay
    uint64_t t1, t2;
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    usleep(10);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (usleep(10)) : %llu\n", t2 - t1);
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    delay(100000);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (delay10K): %llu\n", t2 - t1);
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    delay(1000000);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (delay1M): %llu\n", t2 - t1);
    
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        delay(1000000);
        volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
        if (ret == -1)
        {
            printf("Error setting CPU core affinity. Please run as root\n");
            return EXIT_FAILURE;
        }
        victim();
    } 
    else {
        // Parent = Attacker
        attacker();
    }

    return 0;
}
