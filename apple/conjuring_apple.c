#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <_types/_uint32_t.h>

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
    // Set CPU affinity using KDK interface.
    uint32_t CORE_ID = 0;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t timer_start = 0;
    uint64_t timer_end = 0;

    for (int i = 0; i < testsize; i++) {
        func(0);
        func(0);
        func(0);
        func(0);
        func(0);
        func(0);
        func(1);

        // uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
	    asm volatile("mrs %[timer_start], S3_2_c15_c0_0" : [timer_start]"=r"(timer_start));
        func(GUESS);
        // uint64_t end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
	    asm volatile("mrs %[timer_end], S3_2_c15_c0_0" : [timer_end]"=r"(timer_end));
        // hit[i] = end - start;
        hit[i] = timer_end - timer_start;

        printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }

    for (int i = 0; i < testsize; i++) {
        func(0);

        // uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
	    asm volatile("mrs %[timer_start], S3_2_c15_c0_0" : [timer_start]"=r"(timer_start));
        func(GUESS);
        // uint64_t end = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
	    asm volatile("mrs %[timer_end], S3_2_c15_c0_0" : [timer_end]"=r"(timer_end));
        // miss[i] = end - start;
        miss[i] = timer_end - timer_start;

        printf("[MISS] Time (ns): %llu\n", miss[i]);
    }

    FILE *fp = fopen("conjuring.txt", "w");
    for (int i = 0; i < testsize; i++) {
        fprintf(fp, "%llu,%llu\n", hit[i], miss[i]);
    }
    fclose(fp);

    return 0;
}
