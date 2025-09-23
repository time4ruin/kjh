#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

#define MAX_ENTRIES 5000000
#define THRESHOLD 2.0

typedef struct {
    double time;
    double value;
} DataEntry;

int compare_time(const void *a, const void *b) {
    double diff = (*(DataEntry *)a).time - (*(DataEntry *)b).time;
    return (diff > 0) - (diff < 0);
}

int main() {
    FILE *fp1 = fopen("p1.txt", "r");
    FILE *fp2 = fopen("p2.txt", "r");
    FILE *out = fopen("result.txt", "w");

    if (!fp1 || !fp2 || !out) {
        perror("File open error");
        return 1;
    }

    double *times = malloc(sizeof(double) * MAX_ENTRIES);
    DataEntry *data = malloc(sizeof(DataEntry) * MAX_ENTRIES);
    int *anomaly_counts = calloc(MAX_ENTRIES, sizeof(int));
    int *total_counts = calloc(MAX_ENTRIES, sizeof(int));

    if (!times || !data || !anomaly_counts || !total_counts) {
        perror("Memory allocation failed");
        return 1;
    }

    int times_len = 0, data_len = 0;

    // Read p1.txt (times)
    while (fscanf(fp1, "%lf", &times[times_len]) == 1) {
        times_len++;
    }

    // Read p2.txt (time, value)
    while (fscanf(fp2, "%lf,%lf", &data[data_len].time, &data[data_len].value) == 2) {
        data_len++;
    }

    fclose(fp1);
    fclose(fp2);

    // Sort data by timestamp
    qsort(data, data_len, sizeof(DataEntry), compare_time);

    double data_start = data[0].time;
    double data_end = data[data_len - 1].time;

    // Find overlapping times
    int relevant_start = 0, relevant_end = 0;
    while (relevant_start < times_len && times[relevant_start] < data_start) relevant_start++;
    while (relevant_end < times_len && times[relevant_end] <= data_end) relevant_end++;

    int total = 0, hit = 0;
    int b1c_count[3] = {0, 0, 0};

    int rt_index = relevant_start;

    for (int i = 1; i < data_len - 1; i++) {
        double t1 = data[i - 1].time;
        double t2 = data[i].time;
        double t3 = data[i + 1].time;
        double v1 = data[i - 1].value;
        double v2 = data[i].value;
        double v3 = data[i + 1].value;

        while (rt_index + 1 < relevant_end && t2 >= times[rt_index + 1]) {
            rt_index++;
        }
        if (rt_index >= relevant_end - 1) break;

        double neighbor_avg = (v1 + v3) / 2.0;
        int is_anomaly = v2 > neighbor_avg * THRESHOLD;

        total_counts[rt_index - relevant_start]++;
        if (is_anomaly)
            anomaly_counts[rt_index - relevant_start]++;
    }

    // Output result
    for (int i = 0; i < relevant_end - relevant_start - 1; i++) {
        int b1c = anomaly_counts[i];
        int b1t = total_counts[i];
        fprintf(out, "%lld, %d/%d\n", (long long)times[relevant_start + i], b1c, b1t);

        total++;
        if (b1c >= 1) hit++;
        if (b1c == 0) b1c_count[0]++;
        else if (b1c == 1) b1c_count[1]++;
        else b1c_count[2]++;
    }

    fclose(out);

    printf("\n======== Summary ========\n");
    printf("Total               : %d/%d\n", hit, total);
    printf("misprediction = 0   : %d\n", b1c_count[0]);
    printf("misprediction = 1   : %d\n", b1c_count[1]);
    printf("misprediction >= 2  : %d\n", b1c_count[2]);
    if (total > 0)
        printf("ratio               : %.2f%%\n", (double)hit / total * 100);

    // Free
    free(times);
    free(data);
    free(anomaly_counts);
    free(total_counts);

    return 0;
}
