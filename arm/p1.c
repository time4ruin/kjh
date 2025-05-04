#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

void func1(int input){
	__asm__ __volatile__(
	".rept 10\n\t"
	"nop\n\t"
	".endr\n\t"
	:::);
	if (input){ // 0x40090c
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

int main(){
	int testsec = 2;
	struct timespec ts, start;
	srand(time(NULL));

	printf("[Victim] address of func1: %p\n", func1);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p1.txt", "w");
	do {
		usleep(100);
		int input = rand() % 2;

		func1(1);
		
		clock_gettime(CLOCK_REALTIME, &ts);
		long long nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "%lld\n", nanoseconds);
	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}

