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
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("dsb sy" ::: "memory");
        f1(0); // not-taken
        asm volatile("dsb sy" ::: "memory");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
        hit[i] = t2 - t1;
        printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++) {
        f1(1);
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("dsb sy" ::: "memory");
        f1(0); // not-taken
        asm volatile("dsb sy" ::: "memory");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
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
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    usleep(10);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (usleep(10)) : %llu\n", t2 - t1);
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    delay(100000);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (delay10K): %llu\n", t2 - t1);
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
    asm volatile("dsb sy" ::: "memory");
    delay(1000000);
    asm volatile("dsb sy" ::: "memory");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
    printf("Delay Time (delay1M): %llu\n", t2 - t1);
    
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        // CORE_ID = 0;
        volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
        if (ret == -1)
        {
            printf("Error setting CPU core affinity. Please run as root\n");
            return EXIT_FAILURE;
        }

        char (*lines)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
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

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        while(1) {
            usleep(10);
            int input = rand() % 2;

            f1(1);
            asm volatile("dsb sy" ::: "memory");
            asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
            // fprintf(fp, "%llu\n", now);
            snprintf(lines[n++], MAX_LINE_LENGTH, "%llu\n", now);
            if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
                break;
            }
        }

        for (int i = 0; i < MAX_LINES; ++i) {
            fputs(lines[i], fp);
        }
        fclose(fp);
        free(lines);
        printf("Victim(Child) End\n");
    } 
    else {
        // Parent = Attacker
        
        char (*lines)[MAX_LINE_LENGTH] = malloc(sizeof(char[MAX_LINES][MAX_LINE_LENGTH]));
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

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        uint64_t previous = start;
        while(1) {		
            asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
            asm volatile("dsb sy" ::: "memory");
            f1(0); // not-taken
            asm volatile("dsb sy" ::: "memory");
            asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
            latency = t2 - t1;

            asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
            // fprintf(fp, "%llu, %llu, %llu, %llu\n", t1, t2, t2 - t1, now - previous);
            snprintf(lines[n++], MAX_LINE_LENGTH, "%llu, %llu, %llu, %llu\n", t1, t2, t2 - t1, now - previous);
            previous = now;
            if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
                break;
            }
        }

        for (int i = 0; i < MAX_LINES; ++i) {
            fputs(lines[i], fp);
        }
        fclose(fp);
        free(lines);
        printf("Attacker(Parent) End\n");
    }

    return 0;
}
