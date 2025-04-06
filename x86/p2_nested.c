#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

int input1, input2;

void branch1(){
	if (input1){
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 9994\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

void branch2(){
	if (input2){
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
}

void dummy(){
	srand(time(NULL));
	rand();
	sleep(1);
}

int main(){
	uint64_t t1, t2;
	int testsec = 3;
    int latency;
	long long nanoseconds;
	struct timespec ts, start;

	printf("[Spy] address of func_branch1: %p\n", branch1);
	printf("[Spy] address of func_branch2: %p\n", branch2);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p2_nested.txt", "w");
	do {
		input1 = 0;
		t1 = rdtsc();

		branch1(); // not-taken
		
		t2 = rdtsc();
		latency = (int)(t2 - t1);
		clock_gettime(CLOCK_REALTIME, &ts);
		nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "[b1] %lld,%d\n", nanoseconds, latency);

		input2 = 0;
		t1 = rdtsc();

		branch2(); // not-taken
		
		t2 = rdtsc();
		latency = (int)(t2 - t1);
		clock_gettime(CLOCK_REALTIME, &ts);
		nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "[b2] %lld,%d\n", nanoseconds, latency);

	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}
