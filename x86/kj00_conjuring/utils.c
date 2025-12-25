#include <stdlib.h>
#include <inttypes.h>
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <stdint.h>
#include <time.h>
#include <math.h>

#include "common.h"

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

typedef struct {
    uint64_t value;
    int count;
} Entry;

static int cmp_value_asc(const void *a, const void *b) {
    const Entry *ea = (const Entry *)a;
    const Entry *eb = (const Entry *)b;
    if (ea->value < eb->value) return -1;  // 오름차순
    if (ea->value > eb->value) return 1;
    return 0;
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

    // ★ 여기 확인: compare_desc 말고 cmp_value_asc 사용
    qsort(entries, entry_count, sizeof(Entry), cmp_value_asc);

    // (선택) 정렬 검증
    for (int i = 1; i < entry_count; i++) {
        assert(entries[i-1].value <= entries[i].value);
    }

    printf("=== %s ===\n", label);
    for (int i = 0; i < entry_count; i++) {
        printf("%" PRIu64 ": %d\n", entries[i].value, entries[i].count);
    }
    printf("\n");

    free(entries);
}

double trimmed_mean(uint64_t *arr, size_t n, size_t trim) {
    // n = 100, trim = 20
    // 1. 배열 복사
    uint64_t *copy = malloc(n * sizeof(uint64_t));
    if (!copy) return -1;
    for (size_t i = 0; i < n; i++) copy[i] = arr[i];

    // 2. 오름차순 정렬
    for (size_t i = 0; i < n - 1; i++) {
        for (size_t j = i + 1; j < n; j++) {
            if (copy[i] > copy[j]) {
                uint64_t tmp = copy[i];
                copy[i] = copy[j];
                copy[j] = tmp;
            }
        }
    }

    // 3. trim 만큼 잘라서 평균 계산
    uint64_t sum = 0;
    for (size_t i = trim; i < n - trim; i++) {
        sum += copy[i];
    }

    free(copy);

    return (double)sum / (n - 2 * trim);
}

double trimmed_stddev(uint64_t *arr, size_t n, size_t trim) {
    // n 값이 너무 작아서 양쪽에서 trim 하고 나면 남는 값이 없을 때
    if (n <= 2 * trim) return -1.0;

    // 1. 배열 복사
    uint64_t *copy = malloc(n * sizeof(uint64_t));
    if (!copy) return -1.0;

    for (size_t i = 0; i < n; i++)
        copy[i] = arr[i];

    // 2. 오름차순 정렬 (단순 정렬: 기존 코드 그대로 사용)
    for (size_t i = 0; i < n - 1; i++) {
        for (size_t j = i + 1; j < n; j++) {
            if (copy[i] > copy[j]) {
                uint64_t tmp = copy[i];
                copy[i] = copy[j];
                copy[j] = tmp;
            }
        }
    }

    // 3. trim 구간 제외한 값들로 평균 계산
    size_t start = trim;
    size_t end = n - trim;
    size_t valid_n = end - start;

    double sum = 0.0;
    for (size_t i = start; i < end; i++)
        sum += (double)copy[i];

    double mean = sum / valid_n;

    // 4. 표준편차 계산 (trimmed 데이터에 대해)
    double var_sum = 0.0;
    for (size_t i = start; i < end; i++) {
        double diff = (double)copy[i] - mean;
        var_sum += diff * diff;
    }

    double stddev = sqrt(var_sum / valid_n);  // population stddev 기준

    // 5. 메모리 해제 후 반환
    free(copy);
    return stddev;
}