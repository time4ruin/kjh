#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include "common.h"

void attacker(){
    uint64_t (*lines)[4] = malloc(sizeof(uint64_t[MAX_LINES][4]));
    if (!lines) {
        perror("malloc failed");
        return;
    }

    struct timespec ts, t1, t2;
    int n = 0;

    FILE *fp = fopen("p2.txt", "w");
    printf("[Attacker] address of inner branch: %p\n", inner);

    /* branchless */
    uint64_t counter = 0;
    uint64_t limit = 100000;
    uint64_t latency, now;

    // 종료 조건이 명시적 branch 없이 평가되도록 만듦
    while (1) {
        delay(100000);
        // set_ghr();
        latency = inner(0); // attacker branch
        
        __asm__ volatile ("dsb sy" ::: "memory");
        __asm__ volatile ("isb" ::: "memory");        
        asm volatile("mrs %0, cntvct_el0" : "=r"(now));
        __asm__ volatile ("isb" ::: "memory");
        lines[n][0] = now;
        lines[n][1] = latency;
        n++;

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

    for (int i = 0; i < n; ++i) {
        fprintf(fp, "%lu, %lu\n", lines[i][0], lines[i][1]);
    }
    /* branchless */

    fclose(fp);
    free(lines);
    printf("Attacker(Parent) End\n");
}