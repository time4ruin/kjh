// bits to leak per victim call (1, 2, 4 or 8)
#define BITS 2
// entry size in array2
#define ENTRY_SIZE 512
// amount of measurement steps per leaked index.
#define ITERATIONS 4
// amount of calls to the victim function per measuerement step (ITERATIONS)
#define VICTIM_CALLS 40
// amount of training calls per out-of-bound call to the victim function.
// VICTIM_CALLS should be divisible by TRAINING + 1
#define TRAINING 9
// Set to 1 to run a benchmark
#define BENCHMARK 1
// amount of offsets per byte
#define OFFSETS_PER_BYTE (8 / BITS)
// amount of values in array2
#define VALUES (1 << BITS)

#define THRESHOLD 100

// memory load
#define memory_access(x) __asm__ volatile("LDR x10, [%[addr]]" :: [addr] "r" (x) : "x10", "memory")
