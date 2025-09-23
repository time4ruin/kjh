#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

void victim();
void attacker();

void delay(const uint64_t limit) {
    uint64_t z = 123456789012345ULL;
    uint64_t y = 98765;
    uint64_t count = 0;

    void* labels[] = {&&done, &&loop};

    while (1) {
        asm volatile("udiv %0, %1, %2" : "=r"(z) : "r"(z), "r"(y));

        uint64_t diff = count - limit;
        uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

        count++;

        goto *labels[continue_mask];

loop:
        continue;

done:
        return;
    }
}

int b1(int input){
	struct timespec begin, end;
	clock_gettime(CLOCK_MONOTONIC, &begin);
	if (input){ // 0x40090c
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 9999\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
	clock_gettime(CLOCK_MONOTONIC, &end);
	int latency = (end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
	return latency;
}

int check_conjuring(){
    uint64_t t1, t2, latency;
    int testsize = 10;

    for (int i = 0; i < testsize; i++) {
        b1(0);
		__asm__ volatile ("dmb sy" ::: "memory");
		latency = b1(0); // not-taken
		__asm__ volatile ("dmb sy" ::: "memory");
        printf("[HIT]  Time (ns): %lu\n", latency);
    }
    for (int i = 0; i < testsize; i++) {
        b1(0);
        b1(0);
        b1(0);
        b1(0);
        b1(0);
        b1(0);
        b1(1);
		__asm__ volatile ("dmb sy" ::: "memory");
		latency = b1(0); // not-taken
		__asm__ volatile ("dmb sy" ::: "memory");
        printf("[MISS] Time (ns): %lu\n", latency);
    }

    return 0;
}

int main() {
    check_conjuring();    
    // Test Delay
    struct timespec t1, t2;
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t1);
    __asm__ volatile ("dmb sy" ::: "memory");
    usleep(10);
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t2);
    long long start = (long long)t1.tv_sec * 1000000000LL + t1.tv_nsec;
    long long end = (long long)t2.tv_sec * 1000000000LL + t2.tv_nsec;
    printf("Delay Time (usleep(10)) : %lld\n", start - end);
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t1);
    __asm__ volatile ("dmb sy" ::: "memory");
    delay(100000);
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t2);
    start = (long long)t1.tv_sec * 1000000000LL + t1.tv_nsec;
    end = (long long)t2.tv_sec * 1000000000LL + t2.tv_nsec;
    printf("Delay Time (delay10K) : %lld\n", start - end);
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t1);
    __asm__ volatile ("dmb sy" ::: "memory");
    delay(1000000);
    __asm__ volatile ("dmb sy" ::: "memory");
    clock_gettime(CLOCK_REALTIME, &t2);
    start = (long long)t1.tv_sec * 1000000000LL + t1.tv_nsec;
    end = (long long)t2.tv_sec * 1000000000LL + t2.tv_nsec;
    printf("Delay Time (delay1M) : %lld\n", start - end);
    
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        usleep(100);
        victim();
    } 
    else {
        // Parent = Attacker
        attacker();
    }

    return 0;
}
