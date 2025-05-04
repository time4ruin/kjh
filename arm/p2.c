#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

int func1(int input){
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

void dummy(){
	srand(time(NULL));
	rand();
	sleep(1);
}

int main(){
	int testsec = 3;
    int latency;
	struct timespec ts, start, begin, end;

	printf("[Spy] address of func1: %p\n", func1);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p2.txt", "w");
	do {

		__asm__ volatile ("dmb sy" ::: "memory");
		latency = func1(0); // not-taken
		__asm__ volatile ("dmb sy" ::: "memory");
		
		clock_gettime(CLOCK_REALTIME, &ts);
		long long nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "%lld,%d\n", nanoseconds, latency);

	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}
