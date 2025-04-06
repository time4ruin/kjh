#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

// 평균 계산 함수
int mean(const int *times, int start, int end) {
    long long sum = 0; // 오버플로 방지를 위해 long long 사용
    for (int i = start; i < end; i++) {
        sum += times[i];
    }
    return (int)(sum / (end - start));
}

// 노이즈 탐지 함수
void detect_noise(const int *times, int size, int window_size, int threshold) {
    int num_windows = size / window_size; // 총 구간 수
    int *window_means = (int *)malloc(num_windows * sizeof(int));

    // 각 구간의 평균 계산
    for (int i = 0; i < num_windows; i++) {
        int start = i * window_size;
        int end = start + window_size;
        window_means[i] = mean(times, start, end);
        printf("Window %d-%d: Mean = %d\n", start, end - 1, window_means[i]);
    }

    // 평균값 차이로 노이즈 탐지
    for (int i = 1; i < num_windows; i++) {
        int diff = abs(window_means[i] - window_means[i - 1]);
        if (diff > threshold) {
            printf("Noise detected between Window %d and %d (Mean Diff = %d)\n", i - 1, i, diff);
        }
    }

    free(window_means);
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