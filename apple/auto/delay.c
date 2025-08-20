#include <stdint.h>
#include <mach/mach_time.h>
#include <mach/mach.h>
#include "common.h"

void delay(const uint64_t limit) {
    uint64_t z = 123456789012345ULL;
    uint64_t y = 98765;
    uint64_t count = 0;

    void* labels[] = {&&done, &&loop};

    while (1) {
        // 연산
        asm volatile("udiv %0, %1, %2" : "=r"(z) : "r"(z), "r"(y));

        // 분기 없이 탈출 판정
        uint64_t diff = count - limit;
        uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

        count++;

        goto *labels[continue_mask];

loop:
        continue;

done:
        return;
    }
}

void sleep_nanos(uint64_t nanoseconds) {
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);

    uint64_t now = mach_absolute_time();
    uint64_t deadline = now + nanoseconds * info.denom / info.numer;

    mach_wait_until(deadline);
}