#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>

#include "common.h"

void victim(){
    uint64_t *lines = malloc(sizeof(uint64_t) * MAX_LINES);
    if (!lines) {
        perror("malloc failed");
        return;
    }

    int testsec = 5;
    srand(time(NULL));
    struct timespec ts, start;
    
    FILE *fp = fopen("p1.txt", "w+");
    printf("[Victim] address of func1: %p\n", b1);

    // clock_gettime(CLOCK_REALTIME, &start);
    // do {
    //     usleep(10);
    //     int input = rand() % 2;

    //     b1(input);
    //     clock_gettime(CLOCK_REALTIME, &ts);
    //     long long nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
    //     fprintf(fp, "%lld\n", nanoseconds);
    // } while ((ts.tv_sec - start.tv_sec) < testsec);

    uint64_t counter = 0;
    uint64_t limit = 1000;
    int n = 0;
    while(1) {
        usleep(10);
        int input = rand() % 2;

        b1(0);
        clock_gettime(CLOCK_REALTIME, &ts);
        long long nanoseconds = (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
        lines[n++] = nanoseconds;

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
        fprintf(fp, "%lu\n", lines[i]);
    }
    fclose(fp);
    free(lines);
    printf("Victim(Child) End\n");
}