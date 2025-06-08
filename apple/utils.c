#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

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
        printf("%llu: %d\n", entries[i].value, entries[i].count);
    }
    printf("\n");

    free(entries);
}

