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
