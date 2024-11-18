#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

double calculateMean(int *arr, int n){
    int i, sum = 0;
    for (i = 0; i < n; i++){
        sum += arr[i];
    }
    return (double)sum / n;
}

double calculateStandardDeviation(int *arr, int n){
    int i;
    double mean = calculateMean(arr, n);
    double sum = 0.0;
    for (i = 0; i < n; i++){
        sum += pow(arr[i] - mean, 2);
    }
    return sqrt(sum / n);
}

uint64_t rdtsc() {
	uint64_t a, d;
	asm volatile("mfence");
	asm volatile("rdtsc" : "=a"(a), "=d"(d));
	a = (d << 32) | a;
	asm volatile("mfence");
	return a;
}

void flush(void *p) { asm volatile("clflush 0(%0)\n" : : "c"(p) : "rax"); }
void maccess(void *p) { asm volatile("movq (%0), %%rax\n" : : "c"(p) : "rax"); }
void mfence() { asm volatile("mfence"); }

void func(int input){
	if (input){
		__asm__ __volatile__(
        // ".rept 10000\n\t"
        "nop\n\t"
        // ".endr\n\t"
        :::);
	}
	else {
		__asm__ __volatile__(
        // ".rept 10000\n\t"
        "nop\n\t"
        // ".endr\n\t"
        :::);
	}
}

int size = 1;

int main(){
	uint64_t start, end;
	int testsize = 1000;
    int *hit = (int *)malloc(sizeof(int) * testsize);
    int *whyhit = (int *)malloc(sizeof(int) * testsize);
    int *miss = (int *)malloc(sizeof(int) * testsize);

	// for (int i = 0; i < testsize; i++){
	// 	flush(&size);
	// 	start = rdtsc();
	// 	maccess(&size);
	// 	end = rdtsc();
	// 	miss[i] = (int)(end - start);
	// 	// printf("%d\n", (int)(end - start));
	// }

	// maccess(&size);
	// for (int i = 0; i < testsize; i++){
	// 	start = rdtsc();
	// 	maccess(&size);
	// 	end = rdtsc();
	// 	hit[i] = (int)(end - start);
	// 	// printf("%d\n", (int)(end - start));
	// }

	// printf("hit : %lf (%lf)\n", calculateMean(hit, testsize), calculateStandardDeviation(hit, testsize));
	// printf("miss: %lf (%lf)\n", calculateMean(miss, testsize), calculateStandardDeviation(miss, testsize));


	for (int i = 0; i < testsize; i++){
		func(1);

		start = rdtsc();
		func(1);
		end = rdtsc();
		hit[i] = (int)(end - start);
		// printf("Time (Nano): %lld\n", hit[i]);
	}

	for (int i = 0; i < testsize; i++){
		func(0);
		func(0);
		func(0);
		func(0);
		func(0);
		func(0);
		func(1);

		start = rdtsc();
		func(1);
		end = rdtsc();
		whyhit[i] = (int)(end - start);
		// printf("Time (Nano): %lld\n", hit[i]);
	}
	for (int i = 0; i < testsize; i++){
		func(0);

		start = rdtsc();
		func(1);
		end = rdtsc();
		miss[i] = (int)(end - start);
		// printf("Time (Nano): %lld\n", hit[i]);
	}

    FILE *fp = fopen("conjuring.txt", "w");
	for (int i = 0; i < testsize; i++){
		fprintf(fp, "%d,%d,%d\n", hit[i], whyhit[i], miss[i]);
	}
	fclose(fp);
	return 0;
}

