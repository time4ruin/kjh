#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <sched.h>

#include "common.h"

void branch(int i1)
{
    __asm__ volatile (
        ".global branch_eq_label  \n\t"
        ".global branch_else      \n\t"
        "cmp    %w[i1], #0      \n\t"   // input == 0 ?
        "branch_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch_else       \n\t"   // if == 0 -> jump to else
        "branch_if:               \n\t"
        ".rept 1                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch_end         \n\t"   // 끝으로 점프
        "branch_else:             \n\t"
        ".rept 1                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "nop                       \n\t"   // else 블록
        "branch_end:              \n\t"
        :
        : [i1] "r"(i1)
        : "cc", "memory"
    );
}

void branch_nested(int i1, int i2)
{
    __asm__ volatile(

        /* PAD1 start */
        ".rept 8000                                       \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        /* PAD1 end */


        /* ======================================================
         * if (i1)  ------ 1st branch
         * ====================================================== */
        ".global branch1_eq_label                        \n\t"
        ".global branch1_else                            \n\t"
        "cmp    %w[i1], #0                               \n\t"
        "branch1_eq_label:                               \n\t"
        "b.eq   branch1_else                             \n\t"   // i1 == 0 → else


        /* ===== THEN(i1) ===== */
        "branch1_if:                                     \n\t"

        /* PAD2 start */              
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        /* PAD2 end */ 


        /* ======================================================
         * if (i2)  ------ 2nd branch (nested)
         * ====================================================== */
        ".global branch2_eq_label                        \n\t"
        ".global branch2_else                            \n\t"
        "cmp    %w[i2], #0                               \n\t"
        "branch2_eq_label:                               \n\t"
        "b.eq   branch2_else                             \n\t"   // i2 == 0 → else


        /* ===== THEN(i2) ===== */
        "branch2_if:                                     \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"
        "b      branch2_end                              \n\t"


        /* ===== ELSE(i2) ===== */
        "branch2_else:                                   \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"

        "branch2_end:                                    \n\t"
        "b      branch1_end                              \n\t"


        /* ===== ELSE(i1) ===== */
        "branch1_else:                                   \n\t"
        ".rept 8000                                      \n\t"
        "nop                                             \n\t"
        ".endr                                           \n\t"

        /* ===== END ===== */
        "branch1_end:                                    \n\t"

        :
        : [i1] "r"(i1),
          [i2] "r"(i2)
        : "cc", "memory"
    );
}

int main(){
    uint64_t addr1, addr2, addr3;
    __asm__ volatile(
        "ldr    %0, =branch_eq_label\n\t"   // 절대 주소 로드
        "ldr    %1, =branch1_eq_label\n\t"
        "ldr    %2, =branch2_eq_label\n\t"
        : "=r"(addr1), "=r"(addr2), "=r"(addr3)
        :
        : 
    );
    printf("[VIC] address of single branch: %p\n", (void*)addr1);
    printf("[VIC] address of outer branch: %p\n", (void*)addr2);
    printf("[VIC] address of inner branch: %p\n", (void*)addr3);
    fflush(stdout);

    uint64_t *lines = malloc(sizeof(uint64_t) * MAX_LINES);
    if (!lines) {
        perror("malloc failed");
        return 0;
    }

    uint64_t now;
    int n = 0;

    FILE *fp = fopen("p1.txt", "w");

    /* branchless */       
    uint64_t counter = 0;
    uint64_t limit = 1000;

    // 종료 조건이 명시적 branch 없이 평가되도록 만듦
    while (1) {
        delay(10000000);
        // sched_yield();
        // usleep(100);
        
        branch_nested(1, 1); // victim branch
        // branch(1);

        __asm__ volatile ("dsb sy" ::: "memory");
        __asm__ volatile ("isb" ::: "memory");
        asm volatile("mrs %0, cntvct_el0" : "=r"(now));
        __asm__ volatile ("isb" ::: "memory");
        lines[n++] = now;

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
        fprintf(fp, "%lu\n", lines[i]);
    }
    /* branchless */       

    fclose(fp);
    free(lines);
    printf("Victim(Child) End\n");

    return 0;
}