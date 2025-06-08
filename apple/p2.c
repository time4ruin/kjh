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

void func1(int input){
	if (input){
		__asm__ __volatile__(
        ".rept 8022\n\t"
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
    // Set CPU affinity using KDK interface.
    uint32_t CORE_ID = 0;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

	uint64_t t1, t2;
    uint64_t latency;
	int testsec = 3;

	printf("[Spy] address of func1: %p\n", func1);

	uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
	uint64_t previous = start;
    FILE *fp = fopen("p2.txt", "w");
	while(1) {
		t1 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
		asm volatile("mfence" ::: "memory");
		func1(0); // not-taken
		asm volatile("mfence" ::: "memory");
		t2 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
		latency = t2 - t1;
		
	    // asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1]"=r"(t1));
		// asm volatile("dsb sy" ::: "memory");
		// func1(0); // not-taken
		// asm volatile("dsb sy" ::: "memory");
	    // asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2]"=r"(t2));
		// latency = t2 - t1;

		// fprintf(fp, "%llu, %llu (%llu) - ", t1, t2, t2 - t1);
		uint64_t now = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        fprintf(fp, "%llu, %llu\n", now, latency);
		// fprintf(fp, "%llu, %llu\n", now, now - previous);
		previous = now;
        if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
            break;
        }
	}

	fclose(fp);
	return 0;
}
