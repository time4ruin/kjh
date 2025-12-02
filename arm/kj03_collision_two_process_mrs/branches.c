#include <time.h>

#include "common.h"

void dummy(){
    NOP_REPEAT(1);
}

ATTR
uint64_t branch1(int input)
{
    uint64_t t1, t2;
    asm volatile(".p2align   14\n\t");
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    asm volatile("mrs %0, cntvct_el0" : "=r"(t1));
    __asm__ volatile ("isb" ::: "memory");
    if (input)
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    else
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    __asm__ volatile ("dsb sy" ::: "memory");
    __asm__ volatile ("isb" ::: "memory");
    asm volatile("mrs %0, cntvct_el0" : "=r"(t2));
    __asm__ volatile ("isb" ::: "memory");
    return t2 - t1;
}

ATTR
uint64_t branch2(int input)
{
    uint64_t t1, t2;
    asm volatile(".p2align   14\n\t");
    __asm__ volatile ("dmb sy" ::: "memory");
    asm volatile("mrs %0, cntvct_el0" : "=r"(t1));
    __asm__ volatile ("dmb sy" ::: "memory");
    if (input)
    {
        delay(100);
        // __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    else
    {
        delay(100);
        // __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
    __asm__ volatile ("dmb sy" ::: "memory");
    asm volatile("mrs %0, cntvct_el0" : "=r"(t2));
    __asm__ volatile ("dmb sy" ::: "memory");
    return t2 - t1;
}