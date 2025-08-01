#include <_types/_uint32_t.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include "common.h"

void victim(){
    uint64_t *lines = malloc(sizeof(uint64_t) * MAX_LINES);
    if (!lines) {
        perror("malloc failed");
        return;
    }

    uint64_t now;
    int n = 0;
    
    FILE *fp = fopen("p1.txt", "w");
    printf("[Victim] address of f1: %p\n", f1);

    /* branch branch branch */
    char (*lines2)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
    uint64_t latency, start;
    int testsec = 5; // not second. cycle-based
    asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
    while(1) {
        usleep(10);
        // delay(100000);
        int input = rand() % 2;

        f1(1);
        asm volatile("dsb sy" ::: "memory");
        asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
        // // fprintf(fp, "%llu\n", now);
        snprintf(lines2[n++], MAX_LINE_LENGTH, "%llu\n", now);
        if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
            break;
        }
    }
    for (int i = 0; i < MAX_LINES; ++i) {
        fputs(lines2[i], fp);
    }
    /* branch branch branch */

//     /* branchless */       
//     uint64_t counter = 0;
//     uint64_t limit = 1000;

//     // 종료 조건이 명시적 branch 없이 평가되도록 만듦
//     while (1) {
//         // --- 여기에 하고 싶은 작업 ---
//         delay(100000);
//         asm volatile("dsb ish");
//         asm volatile("isb");
//         f1(0); // victim branch
//         asm volatile("dsb ish");
//         asm volatile("isb");
//         asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
//         asm volatile("isb");
//         lines[n++] = now;

//         // 탈출 처리
//         uint64_t diff = counter - limit;
//         uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

//         // 종료 처리 - branch 없이 loop 탈출
//         // 방법: break_mask를 포인터에 곱해서 null이면 no-op, 아니면 break
//         void* targets[] = {&&break_loop, &&continue_loop};
//         goto *targets[continue_mask];

// continue_loop:
//         counter++;
//     }

// break_loop:
//     printf("Loop ended at counter = %llu\n", counter);

//     for (int i = 0; i < n; ++i) {
//         fprintf(fp, "%llu\n", lines[i]);
//     }
//     /* branchless */       

    fclose(fp);
    free(lines);
    printf("Victim(Child) End\n");
}