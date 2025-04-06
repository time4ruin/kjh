import numpy as np
import traceback

def write_lists_to_file(list1, list2, output_file):
    # 리스트를 문자열로 변환
    line1 = ''.join(map(str, list1))  # 첫 번째 리스트를 0과 1로 연결된 문자열로 변환
    line2 = ''.join(map(str, list2))  # 두 번째 리스트를 0과 1로 연결된 문자열로 변환

    # 파일에 쓰기
    with open(output_file, 'w') as file:
        file.write(line1 + '\n')  # 첫 번째 줄
        file.write(line2 + '\n')  # 두 번째 줄

    print(f"Output written to {output_file}")

def detect_anomalies(p1_file, p2_file, threshold_b1=2.0, threshold_b2=2.0):
    try:
        # 1번 파일에서 비밀 값 읽기
        time_values = []
        with open(p1_file, 'r') as file:
            for line in file:
                parts = line.strip().split(',')
                if len(parts) == 2:
                    time = float(parts[0].strip())
                    value = int(parts[1].strip())
                    time_values.append((time, value))

        # 2번 파일에서 [b1], [b2] 데이터 읽기
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

        # 데이터를 시간 순으로 정렬
        data_b1.sort(key=lambda x: x[0])
        data_b2.sort(key=lambda x: x[0])
        
        # 2번 파일에서 시간 범위 추출
        start_time = min(data_b1, key=lambda x: x[0])[0]
        end_time = max(data_b2, key=lambda x: x[0])[0] 

        # 1번 파일의 시간을 2번 파일의 시간 범위로 필터링
        filtered_values = [value for time, value in time_values if start_time <= time <= end_time]

        # [b1]에서 이상치 탐지
        b1_anomaly_times = []
        mean_b1 = np.mean([v for t, v in data_b1])
        for time, value in data_b1:
            if value > mean_b1 * threshold_b1:
                b1_anomaly_times.append(time)

        # [b2]에서 이상치 탐지
        b1_to_b2_results = []
        for i in range(len(b1_anomaly_times) - 1):
            start_time = b1_anomaly_times[i]
            end_time = b1_anomaly_times[i + 1]

            # [b2] 데이터 필터링
            relevant_b2 = [value for time, value in data_b2 if start_time <= time < end_time]
            if relevant_b2:
                mean_b2 = np.mean(relevant_b2)
                if any(value > mean_b2 * threshold_b2 for value in relevant_b2):
                    b1_to_b2_results.append(1)
                else:
                    b1_to_b2_results.append(0)
            # 이건 그냥 측정 못한거니까 넘어가야함
            # else:
            #     b1_to_b2_results.append(0)

        # 결과 출력
        # print("b1_to_b2_results:", b1_to_b2_results)
        return filtered_values, b1_to_b2_results

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()

# 사용 예시
p1_file = 'p1_nested.txt'
p2_file = 'p2_nested.txt'
p1, p2 = detect_anomalies(p1_file, p2_file, threshold_b1=2.0, threshold_b2=2.0)

write_lists_to_file(p1, p2, 'output.txt')