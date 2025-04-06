#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

void func1(int input){
	if (input){
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
	int testsec = 2;
    int latency;
	struct timespec ts, start;

	printf("[Spy] address of func1: %p\n", func1);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p2.txt", "w");
	do {
		t1 = rdtsc();

		func1(0); // not-taken
		
		t2 = rdtsc();
		clock_gettime(CLOCK_REALTIME, &ts);
		latency = (int)(t2 - t1);
		long long nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "%lld, %d\n", nanoseconds, latency);

	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}
