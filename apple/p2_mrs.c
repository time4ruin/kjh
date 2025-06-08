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

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

void func1(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 8026\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
	}
    else {
		__asm__ __volatile__(
        ".rept 7968\n\t"
        "nop\n\t"
        ".endr\n\t"
        :::);
    }
}

int main(){
	sleep(3);
    // Set CPU affinity using KDK interface.
    uint32_t CORE_ID = 0;
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

	uint64_t t1, t2, now, start;
    uint64_t latency;
	int testsec = 5;
	int n = 0;

    FILE *fp = fopen("p2.txt", "w");
	printf("[Spy] address of func1: %p\n", func1);

	asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
	uint64_t previous = start;
	while(1) {		
	    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
		asm volatile("dsb sy" ::: "memory");
		func1(0); // not-taken
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
	return 0;
}
