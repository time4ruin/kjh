#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <time.h>
#include <unistd.h>
#include <_types/_uint32_t.h>

#define	EXIT_FAILURE	1

int main() {
    // Set CPU affinity using KDK interface.
    uint32_t CORE_ID = 5;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }

    uint64_t timer_val = 0;
	printf("If your patch was successful, the following will not crash:\n");
	asm volatile("mrs %[timer_val], S3_2_c15_c0_0" : [timer_val]"=r"(timer_val));
	printf("Seems like it worked (Timer is %lld)!\n", timer_val);
	asm volatile("mrs %[timer_val], S3_2_c15_c0_0" : [timer_val]"=r"(timer_val));
	printf("Seems like it worked (Timer is %lld)!\n", timer_val);
	asm volatile("mrs %[timer_val], S3_2_c15_c0_0" : [timer_val]"=r"(timer_val));
	printf("Seems like it worked (Timer is %lld)!\n", timer_val);

}
