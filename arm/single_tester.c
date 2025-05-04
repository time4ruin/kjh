#include <stdio.h>
#include <stdlib.h>

#define INITIAL_CAPACITY 100000
#define THRESHOLD 1.5
#define TIME_FILE "p1.txt"
#define DATA_FILE "p2.txt"

typedef struct {
    long long time;
    int value;
} Entry;

int main(void) {
    long long *times = malloc(INITIAL_CAPACITY * sizeof(long long));
    size_t time_size = INITIAL_CAPACITY;
    size_t time_count = 0;

    Entry *data = malloc(INITIAL_CAPACITY * sizeof(Entry));
    size_t data_size = INITIAL_CAPACITY;
    size_t data_count = 0;

    if (!times || !data) {
        perror("Failed to allocate memory");
        return 1;
    }

    // 1. Read times
    FILE *f_time = fopen(TIME_FILE, "r");
    if (!f_time) {
        perror("Failed to open time file");
        return 1;
    }

    while (fscanf(f_time, "%lld", &times[time_count]) == 1) {
        time_count++;
        if (time_count >= time_size) {
            time_size *= 2;
            times = realloc(times, time_size * sizeof(long long));
            if (!times) {
                perror("Failed to realloc times");
                return 1;
            }
        }
    }
    fclose(f_time);

    // 2. Read data
    FILE *f_data = fopen(DATA_FILE, "r");
    if (!f_data) {
        perror("Failed to open data file");
        return 1;
    }

    while (fscanf(f_data, "%lld,%d", &data[data_count].time, &data[data_count].value) == 2) {
        data_count++;
        if (data_count >= data_size) {
            data_size *= 2;
            data = realloc(data, data_size * sizeof(Entry));
            if (!data) {
                perror("Failed to realloc data");
                return 1;
            }
        }
    }
    fclose(f_data);

    if (data_count < 3 || time_count < 2) {
        printf("Insufficient data.\n");
        return 1;
    }

    long long data_start = data[0].time;
    long long data_end = data[data_count - 1].time;

    // 3. Filter times in range
    long long *relevant_times = malloc(time_count * sizeof(long long));
    size_t relevant_count = 0;
    for (size_t i = 0; i < time_count; i++) {
        if (times[i] >= data_start && times[i] <= data_end) {
            relevant_times[relevant_count++] = times[i];
        }
    }

    if (relevant_count < 2) {
        printf("Not enough overlapping time intervals.\n");
        return 1;
    }

    // 4. Detect anomalies
    long long *anomalies = malloc(data_count * sizeof(long long));
    size_t anomaly_count = 0;

    for (size_t i = 1; i < data_count - 1; i++) {
        float avg = (data[i - 1].value + data[i + 1].value) / 2.0;
        if (data[i].value > avg * THRESHOLD) {
            anomalies[anomaly_count++] = data[i].time;
        }
    }

    // 5. Count anomaly intervals
    size_t found = 0;
    for (size_t i = 0; i < relevant_count - 1; i++) {
        long long t1 = relevant_times[i];
        long long t2 = relevant_times[i + 1];
        for (size_t j = 0; j < anomaly_count; j++) {
            if (anomalies[j] >= t1 && anomalies[j] < t2) {
                found++;
                break;
            }
        }
    }

    printf("Total anomaly intervals: %zu/%zu\n", found, relevant_count - 1);

    // Free
    free(times);
    free(data);
    free(relevant_times);
    free(anomalies);

    return 0;
}
