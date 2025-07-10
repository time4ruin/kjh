#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

void attacker(){
    uint64_t (*lines)[3] = malloc(sizeof(uint64_t[MAX_LINES][2]));
    if (!lines) {
        perror("malloc failed");
        return;
    }

    int testsec = 10;
    uint64_t latency;
    struct timespec ts, start;

    FILE *fp = fopen("p2.txt", "w+");
    printf("[Spy] address of f1: %p\n", b1);

    // clock_gettime(CLOCK_REALTIME, &start);
    // do {		
    //     __asm__ volatile ("dmb sy" ::: "memory");
    //     latency = b1(0); // not-taken
    //     __asm__ volatile ("dmb sy" ::: "memory");

    //     clock_gettime(CLOCK_REALTIME, &ts);
    //     long long now = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
    //     fprintf(fp, "%lld,%ld\n", now, latency);
    // } while ((ts.tv_sec - start.tv_sec) < testsec);

    uint64_t counter = 0;
    uint64_t limit = 200000;
    int n = 0;
    clock_gettime(CLOCK_REALTIME, &ts);
    long long previous = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
    while(1) {		
        __asm__ volatile ("dmb sy" ::: "memory");
        latency = b1(0); // not-taken
        __asm__ volatile ("dmb sy" ::: "memory");

        clock_gettime(CLOCK_REALTIME, &ts);
        long long now = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
        lines[n][0] = now;
        lines[n][1] = latency;
        lines[n][2] = now - previous;
        n++;
        previous = now;

        // 탈출 처리
        uint64_t diff = counter - limit;
        uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

        // 종료 처리 - branch 없이 loop 탈출
        // 방법: break_mask를 포인터에 곱해서 null이면 no-op, 아니면 break
        void* targets[] = {&&break_loop, &&continue_loop};
        goto *targets[continue_mask];

continue_loop:
        counter++;
    }

break_loop:
    printf("Loop ended at counter = %lu\n", counter);

    // for (int i = 0; i < MAX_LINES; ++i) {
    //     fputs(lines[i], fp);
    // }
    for (int i = 0; i < n; ++i) {
        fprintf(fp, "%lu, %lu, %lu\n", lines[i][0], lines[i][1], lines[i][2]);
    }
    fclose(fp);
    free(lines);
    printf("Attacker(Parent) End\n");
}