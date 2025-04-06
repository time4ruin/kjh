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

void func(int c1, int c2){
	int result;
	/*
	if (c1) { 
        if (c2) { 
            result = c2 + 42;
        }
    }
	*/
	asm volatile (
        "mov %[c1], %%eax;"
        "cmp $0, %%eax;"
        ".p2align 20, 0x90;"
        ".rept 8;"
        "nop;"
        ".endr;"		
        "je skip_if1;"
        ".rept 10000;"
        "nop;"
        ".endr;"		
		"jmp end0;"

        "mov %[c2], %%ebx;"
        "cmp $0, %%ebx;"
        ".p2align 20, 0x90;"
        ".rept 15;" // offset 8 + 7 bit
        "nop;"
        ".endr;"		
        "je skip_if2;"

        ".rept 10000;"
        "nop;"
        ".endr;"
		"jmp skip_if1;"

        "skip_if2:"
        ".rept 10000;"
        "nop;"
        ".endr;"

        "skip_if1:"
        ".rept 10000;"
        "nop;"
        ".endr;"
		"end0:"	
        : 
        : [c1] "r" (c1), [c2] "r" (c2)
        : "eax", "ebx"
    );

}

int branch_one(unsigned int value){ // (1:Taken, 0:Not-taken)
    uint64_t start, end, d;
    asm volatile(
        "cmp $0x1, %%rcx;"
        ".p2align 20, 0x90;"
        "mfence;"	// 3 bytes
        "rdtsc;"	// 2 bytes
        "mfence;"	// 3 bytes

        "je label1;" // branch
        "nop;"
		"jmp end1;"

        "label1:"
        "nop;"

		"end1:"
        "nop;"
        :"=a"(start), "=d"(d):"c"(value));
    end = rdtsc();
    start = (d << 32) | start;
    return (int)(end - start);
}

int branch_two(unsigned int value){ // (1:Taken, 0:Not-taken)
    uint64_t start, end, d;
    asm volatile(
        "cmp $0x1, %%rcx;"
        ".p2align 20, 0x90;"
        ".rept 7;" // offset 7 bytes
        "nop;"
        ".endr;"
        "mfence;" // 8 bytes
        "rdtsc;"
        "mfence;"
		
        "je label2;" // branch
        ".rept 10000;"
        "nop;"
        ".endr;"
		"jmp end2;"

        "label2:"
        ".rept 10000;"
        "nop;"
        ".endr;"

		"end2:"
        "nop;"
        :"=a"(start), "=d"(d):"c"(value));
    end = rdtsc();
    start = (d << 32) | start;
    return (int)(end - start);
}


int size = 1;

int main(){
	uint64_t start, end;
	int testsize = 10000;
    int *test1 = (int *)malloc(sizeof(int) * testsize);
    int *test2 = (int *)malloc(sizeof(int) * testsize);
    int *test3 = (int *)malloc(sizeof(int) * testsize);
    int *test4 = (int *)malloc(sizeof(int) * testsize);

    int *hit = (int *)malloc(sizeof(int) * testsize);
    int *miss = (int *)malloc(sizeof(int) * testsize);

	for (int i = 0; i < testsize; i++){
		// func(1, 1);
		branch_one(1);
		int latency1 = branch_one(1); //hit
		// int latency2 = branch_two(1); //hit
		test1[i] = latency1;
		// test2[i] = latency2;
	}
	for (int i = 0; i < testsize; i++){
		branch_one(0);
		int latency1 = branch_one(1); //miss
		// int latency2 = branch_two(1); //miss
		test3[i] = latency1;
		// test4[i] = latency2;
	}
	FILE *fp = fopen("attack.txt", "w");
	for (int i = 0; i < testsize; i++){
		// fprintf(fp, "%d,%d,%d,%d\n", test1[i], test2[i], test3[i], test4[i]);
		fprintf(fp, "%d,%d,\n", test1[i], test3[i]);
	}
	fclose(fp);

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

	// for (int i = 0; i < testsize; i++){
	// 	func(0, 0);

	// 	start = rdtsc();
	// 	branch1(0); //hit
	// 	end = rdtsc();
	// 	hit[i] = (int)(end - start);
	// 	start = rdtsc();
	// 	branch2(0); //hit
	// 	end = rdtsc();
	// 	noise1[i] = (int)(end - start);
	// 	// printf("Time (Nano): %lld\n", hit[i]);
	// }

	// for (int i = 0; i < testsize; i++){
	// 	func(1, 0);

	// 	start = rdtsc();
	// 	branch1(0); //miss
	// 	end = rdtsc();
	// 	miss[i] = (int)(end - start);
	// 	start = rdtsc();
	// 	branch2(1); //miss
	// 	end = rdtsc();
	// 	noise2[i] = (int)(end - start);
	// 	// printf("Time (Nano): %lld\n", hit[i]);
	// }

    // FILE *fp = fopen("conjuring.txt", "w");
	// for (int i = 0; i < testsize; i++){
	// 	fprintf(fp, "%d,%d,%d,%d\n", hit[i], noise1[i], miss[i], noise2[i]);
	// }
	// fclose(fp);
	return 0;
}

