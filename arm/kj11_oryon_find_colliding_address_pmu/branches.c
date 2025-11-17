#define _GNU_SOURCE
#include <linux/perf_event.h>
#include <asm/unistd.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "common.h"

#ifndef PMU_TYPE_ARMV8_PMUV3
// 네 장비에서 확인한 값 사용
#define PMU_TYPE_ARMV8_PMUV3 5
#endif

// /sys/bus/event_source/devices/armv8_pmuv3/events/cpu_cycles → event=0x11
#define EVENT_CPU_CYCLES 0x11
#define EVENT_BR_MIS_PRED 0x10
#define EVENT_BR_MIS_PRED_RETIRED 0x22
#define EVENT_COND_BR_MIS_PRED 0x400
#define EVENT_L1I_CACHE 0x14
#define EVENT_L1I_CACHE_REFILL 0x1

static long
perf_event_open(struct perf_event_attr *hw_event,
                pid_t pid, int cpu, int group_fd, unsigned long flags)
{
    return syscall(__NR_perf_event_open, hw_event, pid, cpu, group_fd, flags);
}

// === branch1 offset 조절을 위한 패드 ===
void dummy1(void)
{
    /* NOP start */
	NOP_REPEAT(99);
	/* NOP end */
}

// func() 실행 시 걸린 유저 모드 cpu_cycles만 리턴
ATTR
uint64_t branch1(int input)
{
    struct perf_event_attr pe;
    memset(&pe, 0, sizeof(pe));

    pe.type = PMU_TYPE_ARMV8_PMUV3;  // = 7
    pe.size = sizeof(struct perf_event_attr);
    pe.config = EVENT_L1I_CACHE_REFILL;    // = event ID

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
        ".global branch1_eq_label  \n\t"
        ".global branch1_else      \n\t"
        "cmp    %w[input], #0      \n\t"   // input == 0 ?
        "branch1_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch1_else       \n\t"   // if == 0 -> jump to else
        "branch1_if:               \n\t"
        // ".rept 8000                \n\t"   // then 블록
        // "nop                       \n\t"
        // ".endr                     \n\t"
        "nop                       \n\t"   // then 블록
        "b     branch1_end         \n\t"   // 끝으로 점프
        "branch1_else:             \n\t"
        // ".rept 8000                \n\t"   // then 블록
        // "nop                       \n\t"
        // ".endr                     \n\t"
        "nop                       \n\t"   // else 블록
        "branch1_end:              \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    // ============================

    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
    // if (ioctl(fd, PERF_EVENT_IOC_DISABLE, 0) == -1) {
    //     perror("ioctl DISABLE");
    // }
    __asm__ volatile ("isb" ::: "memory");

    uint64_t count = 0;
    if (read(fd, &count, sizeof(count)) != sizeof(count)) {
        perror("read");
        count = 0;
    }

    close(fd);
    return count;
}

// func() 실행 시 걸린 유저 모드 cpu_cycles만 리턴
ATTR
uint64_t branch2(int input)
{
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

    // === 여기 사이가 측정 구간 ===
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    __asm__ volatile (
        ".global branch2_eq_label  \n\t"
        "cmp    %w[input], #0      \n\t"   // input == 0 ?
        "branch2_eq_label:         \n\t"  // ← 분기 명령어 바로 앞에 label
        "b.eq   branch2_else       \n\t"   // if == 0 -> jump to else
        "branch2_if:               \n\t"
        "nop                       \n\t"   // then 블록
        "b     branch2_end         \n\t"   // 끝으로 점프
        "branch2_else:             \n\t"
        "nop                       \n\t"   // else 블록
        "branch2_end:              \n\t"
        :
        : [input] "r"(input)
        : "cc", "memory"
    );
    __asm__ volatile ("isb" ::: "memory");
    // ============================

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

// int main(void)
// {
//     uint64_t c1 = br_and_measure_pmu(1);
//     uint64_t c2 = br_and_measure_pmu(1);
//     uint64_t c3 = br_and_measure_pmu(1);

//     printf("br_misp #1: %llu\n", (unsigned long long)c1);
//     printf("cycles #2: %llu\n", (unsigned long long)c2);
//     printf("cycles #3: %llu\n", (unsigned long long)c3);

//     return 0;
// }
