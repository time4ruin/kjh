#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define GUESS 1

void func(int input) {
    if (input) {
        __asm__ __volatile__(
            ".rept 5000\n\t"
            "nop\n\t"
            ".endr\n\t"
            :::);
    } else {
        __asm__ __volatile__(
            ".rept 5000\n\t"
            "nop\n\t"
            ".endr\n\t"
            :::);
    }
}

int main() {
    int testsize = 1000;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);

    for (int i = 0; i < testsize; i++) {
        // func(0);
        // func(0);
        // func(0);
        // func(0);
        // func(0);
        // func(0);
        func(1);

        uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        func(GUESS);
        uint64_t end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        hit[i] = end - start;

        // printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }

    for (int i = 0; i < testsize; i++) {
        func(0);

        uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        func(GUESS);
        uint64_t end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        miss[i] = end - start;

        // printf("[MISS] Time (ns): %llu\n", miss[i]);
    }

    FILE *fp = fopen("conjuring.txt", "w");
    for (int i = 0; i < testsize; i++) {
        fprintf(fp, "%llu,%llu\n", hit[i], miss[i]);
    }
    fclose(fp);

    return 0;
}
