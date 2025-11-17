#include <time.h>

#include "common.h"

void inner(int input)
{
    if (input)
    {
        __asm__ __volatile__(
            ".rept 8000\n\t"
            "nop\n\t"
            ".endr\n\t" :::);
    }
    else
    {
        __asm__ __volatile__(
            ".rept 8000\n\t"
            "nop\n\t"
            ".endr\n\t" :::);
    }
}

void outer(int input1, int input2, int flag)
{
    if (input1)
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
        (void)(flag && (delay(10000), 0));
        (void)(flag && (inner(input2), 0));
    }
    else
    {
        __asm__ __volatile__(".rept 8000\n\t nop\n\t .endr\n\t" :::);
    }
}