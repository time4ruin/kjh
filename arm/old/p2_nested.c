#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

int input1, input2;

int branch1(){
	struct timespec begin, end;
	clock_gettime(CLOCK_MONOTONIC, &begin);
	__asm__ __volatile__(
	".rept 2\n\t"
	"nop\n\t"
	".endr\n\t"
	:::);
	if (input1){ // 0x400918
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

int branch2(){
	struct timespec begin, end;
	clock_gettime(CLOCK_MONOTONIC, &begin);
	if (input2){ // 0x414244
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 10000\n\t"
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
	int testsec = 5;
    int latency;
	long long nanoseconds;
	struct timespec ts, start, begin, end;

	printf("[Spy] address of func_branch1: %p\n", branch1);
	printf("[Spy] address of func_branch2: %p\n", branch2);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p2_nested.txt", "w");
	do {
		input1 = 0;

		__asm__ volatile ("dmb sy" ::: "memory");
		latency = branch1(); // not-taken
		__asm__ volatile ("dmb sy" ::: "memory");
		
		clock_gettime(CLOCK_REALTIME, &ts);
		nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "[b1] %lld,%d\n", nanoseconds, latency);

		input2 = 0;

		__asm__ volatile ("dmb sy" ::: "memory");
		latency = branch2(); // not-taken
		__asm__ volatile ("dmb sy" ::: "memory");
		
		clock_gettime(CLOCK_REALTIME, &ts);
		nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "[b2] %lld,%d\n", nanoseconds, latency);

	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}
