import numpy as np
import traceback

def process_files_with_overlap_and_count(time_file, data_file, threshold=2.0):
    try:
        # 1번 파일에서 시간 값 읽기
        with open(time_file, 'r') as file:
            times = [float(line.strip()) for line in file.readlines()]

        # 2번 파일에서 (시간, 데이터) 읽기
        data_entries = []
        with open(data_file, 'r') as file:
            for line in file:
                parts = line.strip().split(',')

                time = float(parts[1].strip())
                value = float(parts[3].strip())
                data_entries.append((time, value))
        
        # 데이터를 시간 순으로 정렬 (필요한 경우)
        data_entries.sort(key=lambda x: x[0])

        # 2번 파일의 시간 범위 추출
        data_start_time = data_entries[0][0]
        data_end_time = data_entries[-1][0]

        # 겹치는 시간 범위만 고려
        relevant_times = [t for t in times if data_start_time <= t <= data_end_time]

        if len(relevant_times) < 2:
            print("Not enough overlapping time intervals between the two files.")
            return

        # 슬라이딩 윈도우 기반 이상치
        anomaly_times = []
        for i in range(1, len(data_entries) - 1):
            t1, v1 = data_entries[i - 1]
            t2, v2 = data_entries[i]
            t3, v3 = data_entries[i + 1]
            neighbor_avg = (v1 + v3) / 2
            if v2 > neighbor_avg * threshold:
                anomaly_times.append(t2)        

        # 구간별로 t1 기준 value, 이상치 개수/전체 개수 기록 + O/X 판별
        transition_info = []
        for i in range(len(relevant_times) - 1):
            t1 = times[i]
            t2 = times[i + 1]
            # value_at_t1 = times[i][1]

            # b1 이상치 개수 & 전체 측정 개수
            b1_anomalies = [t for t in anomaly_times if t1 <= t < t2]
            b1_total = [t for t, _ in data_entries if t1 <= t < t2]

            b1c = len(b1_anomalies)
            b1t = len(b1_total)

            transition_info.append((
                t1, b1c, b1t
            ))

        # Large values 총 개수
        total = 0
        hit = 0
        b1c_count = {0: 0, 1: 0, '2+': 0}

        # 결과 파일 출력
        with open('result.txt', 'w') as f:
            for t1, b1c, b1t in transition_info:
                f.write(f"{int(t1)}, {b1c}/{b1t}\n")
                
                # 통계 수집
                total += 1
                if b1c >= 1:
                    hit += 1
                if b1c in (0, 1):
                    b1c_count[b1c] += 1
                else:
                    b1c_count['2+'] += 1

        # 통계 요약 출력
        print("\n=== Summary ===")
        print(f"Total     : {hit}/{total}")
        print(f"b1c = 0   : {b1c_count[0]}")
        print(f"b1c = 1   : {b1c_count[1]}")
        print(f"b1c >= 2  : {b1c_count['2+']}")

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()

# 사용 예시
time_file = 'p1.txt'
data_file = 'p2.txt'
process_files_with_overlap_and_count(time_file, data_file, threshold=2.0)
