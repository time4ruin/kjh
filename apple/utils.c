#include <stdlib.h>
#include <inttypes.h>
#include <stdio.h>
#include <assert.h>

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
