import numpy as np

def detect_spike_anomalies(time_file, data_file, threshold=1.5):
    try:
        # 1. 시간 기준 파일 읽기
        with open(time_file, 'r') as f:
            times = [float(line.strip()) for line in f.readlines()]

        # 2. 데이터 파일 읽기
        data_entries = []
        with open(data_file, 'r') as f:
            for line in f:
                parts = line.strip().split(',')
                if len(parts) == 2:
                    t = float(parts[0].strip())
                    v = float(parts[1].strip())
                    data_entries.append((t, v))

        if not data_entries or len(times) < 2:
            print("Insufficient data.")
            return

        # 3. 시간 순 정렬
        data_entries.sort(key=lambda x: x[0])
        times.sort()

        # 4. 겹치는 시간 범위 추출
        data_start = data_entries[0][0]
        data_end = data_entries[-1][0]
        relevant_times = [t for t in times if data_start <= t <= data_end]

        if len(relevant_times) < 2:
            print("Not enough overlapping time intervals.")
            return

        # 5. 슬라이딩 윈도우 기반 이상치 탐지
        anomaly_times = []
        for i in range(1, len(data_entries) - 1):
            t1, v1 = data_entries[i - 1]
            t2, v2 = data_entries[i]
            t3, v3 = data_entries[i + 1]

            neighbor_avg = (v1 + v3) / 2
            if v2 > neighbor_avg * threshold:
                anomaly_times.append(t2)

        # 6. 시간 구간에 이상치가 몇 개 중 몇 개 존재하는지 확인
        transition_info = []
        found_count = 0
        for i in range(len(relevant_times) - 1):
            start = relevant_times[i]
            end = relevant_times[i + 1]

            # 해당 구간의 전체 측정값 수
            total_count = sum(1 for t, _ in data_entries if start <= t < end)
            # 해당 구간의 이상치 수
            anomaly_count = sum(1 for t in anomaly_times if start <= t < end)
            if anomaly_count >= 1:
                found_count += 1

            transition_info.append((
                start, end, anomaly_count, total_count
            ))

        with open('result.txt', 'w') as f:
            for start, end, anomaly_count, total_count in transition_info:
                result = 'O' if anomaly_count >= 1 else 'X'
                f.write(f"{int(start)}, {int(end)}, {anomaly_count}/{total_count}, {result}\n")

        print(f"\nTotal anomaly intervals: {found_count}/{len(relevant_times)-1}")

    except Exception as e:
        print(f"Error: {e}")

# 사용 예시
# detect_spike_anomalies("p1.txt", "p2.txt", threshold=1.5)

detect_spike_anomalies("results/5_p1.txt", "results/5_p2.txt", threshold=1.5)

