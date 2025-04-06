#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include "./utils.c"

void func1(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
}

void func2(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
}

void func3(int input, int input2){
	if (input){
		__asm__ __volatile__(
        ".rept 10000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
		if (input2){
			__asm__ __volatile__(
			".rept 10000\n\t"
			"nop\n\t"
			".endr\n\t"
			:::);
		}
		else {
			__asm__ __volatile__(
			".rept 1\n\t"
			"nop\n\t"
			".endr\n\t"
			:::);
		}
	}
}

int main(){
	uint64_t start, end;
	int testsize = 10000;
    int *hit = (int *)malloc(sizeof(int) * testsize);
    int *whyhit = (int *)malloc(sizeof(int) * testsize);
    int *miss = (int *)malloc(sizeof(int) * testsize);

	printf("address of func1: %p\n", func1);
	printf("address of func2: %p\n", func2);

	for (int i = 0; i < testsize; i++){
		func1(1);

		start = rdtsc();
		func2(1);
		end = rdtsc();
		hit[i] = (int)(end - start);
	}

	for (int i = 0; i < testsize; i++){
		func1(0);

		start = rdtsc();
		func2(1);
		end = rdtsc();
		miss[i] = (int)(end - start);
	}

	// for (int i = 0; i < testsize; i++){
	// 	func(0);
	// 	func(0);
	// 	func(0);
	// 	func(0);
	// 	func(0);
	// 	func(0);
	// 	func(1);

	// 	start = rdtsc();
	// 	func(1);
	// 	end = rdtsc();
	// 	whyhit[i] = (int)(end - start);
	// }

 	// 노이즈 탐지
    int window_size = testsize / 10; // 구간 크기
    int threshold = 100;     // 평균값 차이 임계값
    detect_noise(hit, testsize, window_size, threshold);
    detect_noise(miss, testsize, window_size, threshold);
    // detect_noise(whyhit, testsize, window_size, threshold);

    FILE *fp = fopen("conjuring.txt", "w");
	for (int i = 0; i < testsize; i++){
		fprintf(fp, "%d\n", hit[i]);
	}
	for (int i = 0; i < testsize; i++){
		fprintf(fp, "%d\n", miss[i]);
	}
	// for (int i = 0; i < testsize; i++){
	// 	fprintf(fp, "%d\n", whyhit[i]);
	// }
	fclose(fp);
	return 0;
}

