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

typedef struct {
    uint64_t value;
    int count;
} Entry;

int compare_desc(const void *a, const void *b) {
    return ((Entry*)b)->count - ((Entry*)a)->count;
}

void print_histogram(uint64_t *arr, int size, const char *label) {
    Entry *entries = malloc(sizeof(Entry) * size);
    int entry_count = 0;

    for (int i = 0; i < size; i++) {
        uint64_t v = arr[i];
        int found = 0;
        for (int j = 0; j < entry_count; j++) {
            if (entries[j].value == v) {
                entries[j].count++;
                found = 1;
                break;
            }
        }
        if (!found) {
            entries[entry_count].value = v;
            entries[entry_count].count = 1;
            entry_count++;
        }
    }

    qsort(entries, entry_count, sizeof(Entry), compare_desc);

    printf("=== %s ===\n", label);
    for (int i = 0; i < entry_count; i++) {
        printf("%lu: %d\n", entries[i].value, entries[i].count);
    }
    printf("\n");

    free(entries);
}

// uint64_t rdtsc() {
// 	uint64_t a, d;
// 	asm volatile("mfence");
// 	asm volatile("rdtsc" : "=a"(a), "=d"(d));
// 	a = (d << 32) | a;
// 	asm volatile("mfence");
// 	return a;
// }
