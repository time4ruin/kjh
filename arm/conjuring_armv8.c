#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define GUESS 1

void func(int input){
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

int main(){
	struct timespec begin, end;
	int testsize = 1000;
    int *hit = (int *)malloc(sizeof(int) * testsize);
    int *miss = (int *)malloc(sizeof(int) * testsize);

	for (int i = 0; i < testsize; i++){
		func(0);
		func(0);
		func(0);
		func(0);
		func(0);
		func(0);
		func(1);

		int cycles = clock_gettime(CLOCK_MONOTONIC, &begin);
		func(GUESS);
		clock_gettime(CLOCK_MONOTONIC, &end);
		hit[i] = (end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
	}
	for (int i = 0; i < testsize; i++){
		func(0);

		int cycles = clock_gettime(CLOCK_MONOTONIC, &begin);
		func(GUESS);
		clock_gettime(CLOCK_MONOTONIC, &end);
		miss[i] = (end.tv_sec - begin.tv_sec) + (end.tv_nsec - begin.tv_nsec);
	}

    FILE *fp = fopen("conjuring.txt", "w");
	for (int i = 0; i < testsize; i++){
		fprintf(fp, "%d,%d\n", hit[i], miss[i]);
	}
	fclose(fp);
	return 0;
}
