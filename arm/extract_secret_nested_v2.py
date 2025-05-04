import numpy as np
import traceback

def write_lists_to_file(list1, list2, output_file):
    line1 = ''.join(map(str, list1))
    line2 = ''.join(map(str, list2))
    with open(output_file, 'w') as file:
        file.write(line1 + '\n')
        file.write(line2 + '\n')
    print(f"Output written to {output_file}")

def detect_anomalies(p1_file, p2_file, threshold_b1=1.2, threshold_b2=1.2):
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
        data_b2 = []
        with open(p2_file, 'r') as file:
            for line in file:
                parts = line.strip().split(' ')
                if len(parts) == 2:
                    category, rest = parts[0].strip(), parts[1].strip()
                    time, value = map(float, rest.split(','))
                    if "[b1]" in category:
                        data_b1.append((time, value))
                    elif "[b2]" in category:
                        data_b2.append((time, value))

        if len(data_b1) < 3 or len(data_b2) < 3:
            print("Not enough data for sliding window analysis.")
            return

        data_b1.sort()
        data_b2.sort()

        # 시간 범위 확인 및 p1 필터링
        start_time = min(data_b1[0][0], data_b2[0][0])
        end_time = max(data_b1[-1][0], data_b2[-1][0])
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

        # [b2] 슬라이딩 윈도우 기반 이상치 시간 추출
        b2_anomaly_times = []
        for i in range(1, len(data_b2) - 1):
            t1, v1 = data_b2[i - 1]
            t2, v2 = data_b2[i]
            t3, v3 = data_b2[i + 1]
            neighbor_avg = (v1 + v3) / 2
            if v2 > neighbor_avg * threshold_b2:
                b2_anomaly_times.append(t2)

        # b1 이상치 사이 구간에 b2 이상치가 존재하는지 확인
        b1_to_b2_results = []
        for i in range(len(b1_anomaly_times) - 1):
            s = b1_anomaly_times[i]
            e = b1_anomaly_times[i + 1]
            if any(s <= t < e for t in b2_anomaly_times):
                b1_to_b2_results.append(1)
            else:
                b1_to_b2_results.append(0)

        # 구간별로 t1 기준 value, 이상치 개수/전체 개수 기록 + O/X 판별
        transition_info = []
        for i in range(len(filtered_values) - 1):
            t1 = time_values[i][0]
            t2 = time_values[i + 1][0]
            value_at_t1 = time_values[i][1]

            # b1 이상치 개수 & 전체 측정 개수
            b1_anomalies = [t for t in b1_anomaly_times if t1 <= t < t2]
            b1_total = [t for t, _ in data_b1 if t1 <= t < t2]

            # b2 이상치 개수 & 전체 측정 개수
            b2_anomalies = [t for t in b2_anomaly_times if t1 <= t < t2]
            b2_total = [t for t, _ in data_b2 if t1 <= t < t2]

            b1c = len(b1_anomalies)
            b2c = len(b2_anomalies)
            b1t = len(b1_total)
            b2t = len(b2_total)

            # O/X 판정
            if (value_at_t1 == 1 and b1c >= 1 and b2c >= 1) or \
               (value_at_t1 == 0 and b1c >= 1 and b2c == 0):
                result = 'Success'
            else:
                result = 'Fail'

            transition_info.append((
                t1, value_at_t1, b1c, b1t, b2c, b2t, result
            ))

        # 결과 파일 출력
        with open('result_nested.txt', 'w') as f:
            for t1, val, b1c, b1t, b2c, b2t, result in transition_info:
                b1_flag = 'O' if b1c >= 1 else 'X'
                f.write(f"{int(t1)}, {val}, {b1c}/{b1t}, {b2c}/{b2t}, {b1_flag}, {result}\n")


        return filtered_values, b1_to_b2_results

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()

# 사용 예시
p1_file = 'p1_nested.txt'
p2_file = 'p2_nested.txt'
p1, p2 = detect_anomalies(p1_file, p2_file, threshold_b1=2, threshold_b2=2)
write_lists_to_file(p1, p2, 'output.txt')
