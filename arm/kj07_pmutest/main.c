#define _GNU_SOURCE
#include <linux/perf_event.h>
#include <asm/unistd.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef PMU_TYPE_ARMV8_PMUV3
// 네 장비에서 확인한 값 사용
#define PMU_TYPE_ARMV8_PMUV3 7
#endif

// /sys/bus/event_source/devices/armv8_pmuv3/events/cpu_cycles → event=0x11
#define EVENT_CPU_CYCLES 0x11
#define EVENT_BR_MID_PRED 0x10
#define EVENT_BR_MID_PRED_RETIRED 0x22

static long
perf_event_open(struct perf_event_attr *hw_event,
                pid_t pid, int cpu, int group_fd, unsigned long flags)
{
    return syscall(__NR_perf_event_open, hw_event, pid, cpu, group_fd, flags);
}

// 예시용 타깃 함수 (여기에 branch 실험 코드나 원하는 코드 넣으면 됨)
void target_func(void)
{
    volatile uint64_t z = 123456789012345ULL;
    volatile uint64_t y = 98765ULL;

    for (int i = 0; i < 100000; i++) {
        __asm__ volatile(
            "udiv %0, %0, %1"
            : "+r"(z)
            : "r"(y)
        );
    }
}

// func() 실행 시 걸린 유저 모드 cpu_cycles만 리턴
uint64_t measure_func_cycles(void (*func)(void))
{
    struct perf_event_attr pe;
    memset(&pe, 0, sizeof(pe));

    pe.type = PMU_TYPE_ARMV8_PMUV3;  // = 7
    pe.size = sizeof(struct perf_event_attr);
    pe.config = EVENT_CPU_CYCLES;    // = event ID

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
    int i = 0;
    if (i==0){
        i++;
    }
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

int main(void)
{
    uint64_t c1 = measure_func_cycles(target_func);
    uint64_t c2 = measure_func_cycles(target_func);
    uint64_t c3 = measure_func_cycles(target_func);

    printf("cycles #1: %llu\n", (unsigned long long)c1);
    printf("cycles #2: %llu\n", (unsigned long long)c2);
    printf("cycles #3: %llu\n", (unsigned long long)c3);

    return 0;
}
