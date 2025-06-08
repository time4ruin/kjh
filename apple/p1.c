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

int main(){
    // Set CPU affinity using KDK interface.
    uint32_t CORE_ID = 0;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }
	
	int testsec = 2;
	srand(time(NULL));

	printf("[Victim] address of func1: %p\n", func1);

	uint64_t start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
    FILE *fp = fopen("p1.txt", "w");
	while(1) {
		usleep(100);
		int input = rand() % 2;

		func1(1);
		
		uint64_t now = clock_gettime_nsec_np(CLOCK_UPTIME_RAW);
        fprintf(fp, "%llu\n", now);
        if ((now - start) >= (uint64_t)testsec * 1000000000ULL) {
            break;
        }
	}

	fclose(fp);
	return 0;
}

