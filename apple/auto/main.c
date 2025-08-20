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
        delay(1000);
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
        delay(1000);
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

void inner(int input){
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

void outer(int input1, int input2, int flag){
	if (input1){
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
        (void)(flag && (delay(10000), 0));
        (void)(flag && (inner(input2), 0));
	}
    else {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
}

inline __attribute__((always_inline))
uint64_t rdtsc()
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

int tests(){
    uint64_t t1, t2;
    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    int input = 0;

    //cache hit,miss
    probe(&input);
    uint64_t a = probe(&input);
    clflush(&input);
    uint64_t b = probe(&input);
    printf("Hit test - %llu\nMiss test - %llu\n", a, b);

    //conjuring test
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
        // f1(0); // not-taken
        // f1(0); // not-taken
        // f1(0); // not-taken
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

    // Test Delay
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
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    sleep_nanos(10);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (sleep_nanos(10)): %llu\n", t2 - t1);
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    sleep_nanos(1000);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (sleep_nanos(1000)): %llu\n", t2 - t1);

    //test attacker loop latency
    uint64_t (*lines)[4] = malloc(sizeof(uint64_t[MAX_LINES][4]));
    int n = 0;
    uint64_t previous, start, end;
    asm volatile("mrs %[previous], S3_2_c15_c0_0" : [previous]"=r"(previous));
    uint64_t counter = 0;
    uint64_t limit = 100000;
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
    asm volatile("isb");
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("isb");
    f1(0); // attacker branch
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    asm volatile("isb");
    lines[n][0] = t1;
    lines[n][1] = t2;
    lines[n][2] = t2 - t1;
    lines[n][3] = t2 - previous;
    n++;
    previous = t2;

    // 탈출 처리
    uint64_t diff = counter - limit;
    uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

    // 종료 처리 - branch 없이 loop 탈출
    // 방법: break_mask를 포인터에 곱해서 null이면 no-op, 아니면 break
    void* targets[] = {&&break_loop, &&continue_loop};
    goto *targets[continue_mask];

continue_loop:
break_loop:
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[end], S3_2_c15_c0_0" : [end]"=r"(end));
    asm volatile("isb");
    printf("Attacker Loop Time: %llu\n", end - start);

    return 0;
}

int main() {
    uint32_t CORE_ID = 5;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

    tests();
    
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        // CORE_ID = 7;
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
