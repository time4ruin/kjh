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
        // 첫 번째 if (c1)
        "mov %[c1], %%eax \n\t"     // c1 값을 eax에 로드
        "cmp $0, %%eax \n\t"        // eax와 0 비교
		".p2align 16, 0x90 \n\t"     // 16바이트 경계로 정렬
        "je skip_if1 \n\t"          // c1이 0이면 첫 번째 if문 스킵

        // 두 번째 if (c2)
        "mov %[c2], %%ebx \n\t"     // c2 값을 ebx에 로드
        "cmp $0, %%ebx \n\t"        // ebx와 0 비교
		".p2align 16, 0x90 \n\t"     // 16바이트 경계로 정렬
		"nop;nop;nop;nop;nop;nop;nop; \n\t"
        "je skip_if2 \n\t"          // c2가 0이면 두 번째 if문 스킵

        // 의미없는 연산: c2 + 42
        "add $42, %%ebx \n\t"       // ebx에 42를 더함
        "mov %%ebx, %[result] \n\t" // 결과를 result에 저장

        "skip_if2: \n\t"            // 두 번째 if문 종료
        "skip_if1: \n\t"            // 첫 번째 if문 종료

        : [result] "=r" (result)    // 출력
        : [c1] "r" (c1), [c2] "r" (c2) // 입력
        : "eax", "ebx"              // 변경된 레지스터
    );
}

void branch0(int c1){
	asm volatile (
        // 첫 번째 if (c1)
        "mov %[c1], %%eax \n\t"     // c1 값을 eax에 로드
        "cmp $0, %%eax \n\t"        // eax와 0 비교
		".p2align 16, 0x90 \n\t"     // 16바이트 경계로 정렬
        "je att_if \n\t"          // c1이 0이면 첫 번째 if문 스킵

        "nop;nop;nop;nop;nop; \n\t" 

        "att_if: \n\t"            // 두 번째 if문 종료

        :: [c1] "r" (c1)			// 입력
        : "eax"             		// 변경된 레지스터
    );
}

void branch1(int c1){
	asm volatile (
        // 첫 번째 if (c1)
        "mov %[c1], %%eax \n\t"     // c1 값을 eax에 로드
        "cmp $0, %%eax \n\t"        // eax와 0 비교
		".p2align 16, 0x90 \n\t"     // 16바이트 경계로 정렬
        "je att_if1 \n\t"          // c1이 0이면 첫 번째 if문 스킵

        "nop;nop;nop;nop;nop; \n\t" 

        "att_if1: \n\t"            // 두 번째 if문 종료

        :: [c1] "r" (c1)			// 입력
        : "eax"             		// 변경된 레지스터
    );
}

void branch2(int c2){
	asm volatile (
        // 두 번째 if (c2)
        "mov %[c2], %%eax \n\t"     // c1 값을 eax에 로드
        "cmp $0, %%eax \n\t"        // eax와 0 비교
		".p2align 16, 0x90 \n\t"     // 16바이트 경계로 정렬
		"nop;nop;nop;nop;nop;nop;nop; \n\t"
        "je att_if2 \n\t"          // c1이 0이면 첫 번째 if문 스킵

        "nop;nop;nop;nop;nop; \n\t" 

        "att_if2: \n\t"            // 두 번째 if문 종료

        :: [c2] "r" (c2)			// 입력
        : "eax"             		// 변경된 레지스터
    );
}

int size = 1;

int main(){
	uint64_t start, end;
	int testsize = 10000;
    int *hittest = (int *)malloc(sizeof(int) * testsize);
    int *hit = (int *)malloc(sizeof(int) * testsize);
    int *miss = (int *)malloc(sizeof(int) * testsize);
    int *noise1 = (int *)malloc(sizeof(int) * testsize);
    int *noise2 = (int *)malloc(sizeof(int) * testsize);

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
		branch0(1);
		start = rdtsc();
		branch1(1); //hit
		end = rdtsc();
		hittest[i] = (int)(end - start);
	}
	FILE *fp = fopen("attack.txt", "w");
	for (int i = 0; i < testsize; i++){
		fprintf(fp, "%d\n", hittest[i]);
	}
	fclose(fp);

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

