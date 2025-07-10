#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include "./utils.c"

int input1, input2;

void func1(){
	usleep(2000);
	__asm__ __volatile__(
	".rept 9\n\t"
	"nop\n\t"
	".endr\n\t"
	:::);
	if (input1){ // 0x400918
		usleep(2000);
		__asm__ __volatile__(
        ".rept 20036\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
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
	int testsec = 3;
	long long nanoseconds;
	struct timespec ts, start;
	srand(time(NULL));

	printf("[Victim] address of func1: %p\n", func1);

	clock_gettime(CLOCK_REALTIME, &start);
    FILE *fp = fopen("p1_nested.txt", "w");
	do {
		usleep(100);
		input1 = 1;
		input2 = rand() % 2;

		func1();
		
		clock_gettime(CLOCK_REALTIME, &ts);
		nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
		fprintf(fp, "%lld,%d\n", nanoseconds, input2);
	} while ((ts.tv_sec - start.tv_sec) < testsec);

	fclose(fp);
	return 0;
}

