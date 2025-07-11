#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include <string.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <_types/_uint32_t.h>

#include "./utils.c"

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

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

void f1(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

int check_conjuring(){
    uint64_t t1, t2, latency;
    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);

    for (int i = 0; i < testsize; i++) {
        f1(0);
        t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        f1(0); // not-taken
        t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        hit[i] = t2 - t1;
        printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++) {
        f1(1);
        t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        f1(0); // not-taken
        t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        miss[i] = t2 - t1;
        printf("[MISS] Time (ns): %llu\n", miss[i]);
    }

    print_histogram(hit, testsize, "HIT");
    print_histogram(miss, testsize, "MISS");
    free(hit);
    free(miss);
    return 0;
}

int main() {
    uint32_t CORE_ID = 3;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }
    check_conjuring();
    // Test Delay
    uint64_t t1, t2;
    t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    usleep(10);
    t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    printf("Delay Time (usleep(10)) : %llu\n", t2 - t1);
    t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    delay(100000);
    t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    printf("Delay Time (delay10K): %llu\n", t2 - t1);
    t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    delay(1000000);
    t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    printf("Delay Time (delay1M): %llu\n", t2 - t1);
    
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        
        volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
        if (ret == -1)
        {
            printf("Error setting CPU core affinity. Please run as root\n");
            return EXIT_FAILURE;
        }

        // char (*lines)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
        uint64_t *lines = malloc(sizeof(uint64_t) * MAX_LINES);
        if (!lines) {
            perror("malloc failed");
            return 1;
        }

        int testsec = 5;
        srand(time(NULL));
        uint64_t now, start;
        int n = 0;
        
        FILE *fp = fopen("p1.txt", "w");
        printf("[Victim] address of func1: %p\n", f1);

        /* branchless */       
        uint64_t counter = 0;
        uint64_t limit = 1000;

        // 종료 조건이 명시적 branch 없이 평가되도록 만듦
        while (1) {
            // --- 여기에 하고 싶은 작업 ---
            delay(100000);
            f1(0); // victim branch
            now = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
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
        printf("Loop ended at counter = %llu\n", counter);

        for (int i = 0; i < n; ++i) {
            fprintf(fp, "%llu\n", lines[i]);
        }
        /* branchless */
            fclose(fp);
            free(lines);
            printf("Victim(Child) End\n");
        } 
    else {
        // Parent = Attacker
        
        // char (*lines)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
        uint64_t (*lines)[3] = malloc(sizeof(uint64_t[MAX_LINES][3]));
        if (!lines) {
            perror("malloc failed");
            return 1;
        }

        uint64_t t1, t2, now, start;
        uint64_t latency;
        int testsec = 15; // not second. cycle-based
        int n = 0;

        FILE *fp = fopen("p2.txt", "w");
        printf("[Spy] address of f1: %p\n", f1);

        /* branchless */
        uint64_t counter = 0;
        uint64_t limit = 2000000;

        // 종료 조건이 명시적 branch 없이 평가되도록 만듦
        while (1) {
            // --- 여기에 하고 싶은 작업 ---
            t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
            f1(1); // attacker branch
            t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
            lines[n][0] = t1;
            lines[n][1] = t2;
            lines[n][2] = t2 - t1;
            n++;

            // 탈출 처리
            uint64_t diff = counter - limit;
            uint64_t continue_mask = (diff >> 63) & 1;  // 1이면 반복, 0이면 종료

            // 종료 처리 - branch 없이 loop 탈출
            // 방법: break_mask를 포인터에 곱해서 null이면 no-op, 아니면 break
            void* targets[] = {&&break_loop2, &&continue_loop2};
            goto *targets[continue_mask];

    continue_loop2:
            counter++;
        }

    break_loop2:
        printf("Loop ended at counter = %llu\n", counter);

        for (int i = 0; i < n; ++i) {
            fprintf(fp, "%llu, %llu, %llu, %llu\n", lines[i][0], lines[i][1], lines[i][2], lines[i][2]);
        }
        /* branchless */
        fclose(fp);
        free(lines);
        printf("Attacker(Parent) End\n");
    }

    return 0;
}
