#include "common.h"

uint64_t branch1(int input)
{
    uint64_t t1, t2;
    asm volatile(".p2align   14\n\t");
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1] "=r"(t1));
    asm volatile("isb");
    if (input)
    {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
    else
    {
		__asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2] "=r"(t2));
    asm volatile("isb");
    return t2 - t1;
}

void dummy_001()
{
    asm volatile(".p2align   14\n\t");
    __asm__ __volatile__("nop");
}
void dummy_002()
{
    asm volatile(".p2align   14\n\t");
    __asm__ __volatile__("nop");
}

uint64_t branch2(int input)
{
    uint64_t t1, t2;
    asm volatile(".p2align   14\n\t");
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t1], S3_2_c15_c0_0" : [t1] "=r"(t1));
    asm volatile("isb");
    if (input)
    {
        delay(100);
		// __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
    else
    {
        delay(100);
		// __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t":::);
    }
    asm volatile("dsb ish");
    asm volatile("isb");
    asm volatile("mrs %[t2], S3_2_c15_c0_0" : [t2] "=r"(t2));
    asm volatile("isb");
    return t2 - t1;
}