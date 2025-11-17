import numpy as np
import traceback

def detect_anomalies(p1_file, p2_file, threshold_b1=1.2):
    try:
        # 1번 파일: (시간, 비밀값)
        time_values = []
        with open(p1_file, 'r') as file:
            for line in file:
                parts = line.strip().split(',')
                if len(parts) == 2:
                    time = float(parts[0].strip())
                    value = int(parts[1].strip())
                    time_values.append((time, value))

        # 2번 파일: [b1], [b2]로 분류
        data_b1 = []
        with open(p2_file, 'r') as file:
            for line in file:
                parts = line.strip().split(' ')
                if len(parts) == 2:
                    category, rest = parts[0].strip(), parts[1].strip()
                    time, value = map(float, rest.split(','))
                    if "[b1]" in category:
                        data_b1.append((time, value))

        if len(data_b1) < 3:
            print("Not enough data for sliding window analysis.")
            return

        data_b1.sort()

        # 시간 범위 확인 및 p1 필터링
        start_time = data_b1[0][0]
        end_time = data_b1[-1][0]
        filtered_values = [value for time, value in time_values if start_time <= time <= end_time]

        # [b1] 슬라이딩 윈도우 기반 이상치
        b1_anomaly_times = []
        for i in range(1, len(data_b1) - 1):
            t1, v1 = data_b1[i - 1]
            t2, v2 = data_b1[i]
            t3, v3 = data_b1[i + 1]
            neighbor_avg = (v1 + v3) / 2
            if v2 > neighbor_avg * threshold_b1:
                b1_anomaly_times.append(t2)

        # 구간별로 t1 기준 value, 이상치 개수/전체 개수 기록 + O/X 판별
        transition_info = []
        for i in range(len(filtered_values) - 1):
            t1 = time_values[i][0]
            t2 = time_values[i + 1][0]
            value_at_t1 = time_values[i][1]

            # b1 이상치 개수 & 전체 측정 개수
            b1_anomalies = [t for t in b1_anomaly_times if t1 <= t < t2]
            b1_total = [t for t, _ in data_b1 if t1 <= t < t2]

            b1c = len(b1_anomalies)
            b1t = len(b1_total)

            transition_info.append((
                t1, value_at_t1, b1c, b1t
            ))

        # 결과 파일 출력
        with open('result_nested_onlyb1.txt', 'w') as f:
            for t1, val, b1c, b1t in transition_info:
                b1_flag = 'O' if b1c >= 1 else 'X'
                f.write(f"{int(t1)}, {val}, {b1c}/{b1t}, {b1_flag}\n")

        return filtered_values

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()

# 사용 예시
p1_file = 'p1_nested.txt'
p2_file = 'p2_nested_onlyb1.txt'
p1 = detect_anomalies(p1_file, p2_file, threshold_b1=1.5)
