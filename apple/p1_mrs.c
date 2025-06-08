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

	int testsec = 3;
	srand(time(NULL));
	uint64_t now, start;
    int n = 0;
    
    FILE *fp = fopen("p1.txt", "w");
	printf("[Victim] address of func1: %p\n", func1);

	asm volatile("mrs %[start], S3_2_c15_c0_0" : [start]"=r"(start));
	while(1) {
		usleep(100);
		int input = rand() % 2;

		func1(1);
		
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
	return 0;
}

