#include <_types/_uint32_t.h>
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

    uint64_t t1, t2;
    int n = 0;

    FILE *fp = fopen("p2.txt", "w");
    printf("[Attacker] address of f1: %p\n", f1);

    // /* branch branch branch */
    // char (*lines2)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
    // int testsec = 15;
    // uint64_t start, now, latency;
    // asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
    // uint64_t previous = start;
    // while(1) {		
    //     asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    //     asm volatile("dsb sy" ::: "memory");
    //     f1(0); // not-taken
    //     asm volatile("dsb sy" ::: "memory");
    //     asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    //     latency = t2 - t1;

    //     asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
    //     // fprintf(fp, "%llu, %llu, %llu, %llu\n", t1, t2, t2 - t1, now - previous);
    //     snprintf(lines2[n++], MAX_LINE_LENGTH, "%llu, %llu, %llu, %llu\n", t1, t2, t2 - t1, now - previous);
    //     previous = now;
    //     if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
    //         break;
    //     }
    // }
    // for (int i = 0; i < MAX_LINES; ++i) {
    //     fputs(lines2[i], fp);
    // }
    // /* branch branch branch */

    /* branchless */
    uint64_t counter = 0;
    uint64_t limit = 2000000;
    uint64_t previous;
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[previous], S3_2_c15_c0_0" : [previous]"=r"(previous));
    asm volatile("isb");

    // 종료 조건이 명시적 branch 없이 평가되도록 만듦
    while (1) {
        // --- 여기에 하고 싶은 작업 ---
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("isb");
        f1(1); // attacker branch
        asm volatile("dsb ish");
        asm volatile("isb");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
        asm volatile("isb");
        lines[n][0] = t1;
        lines[n][1] = t2;
        lines[n][2] = t2 - t1;
        lines[n][3] = t2 - previous;
        n++;
        previous = t2;

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
    printf("Loop ended at counter = %llu\n", counter);

    for (int i = 0; i < n; ++i) {
        fprintf(fp, "%llu, %llu, %llu, %llu\n", lines[i][0], lines[i][1], lines[i][2], lines[i][3]);
    }
    /* branchless */

    fclose(fp);
    free(lines);
    printf("Attacker(Parent) End\n");
}