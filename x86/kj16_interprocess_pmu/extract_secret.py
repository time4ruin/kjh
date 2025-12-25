import numpy as np
import traceback

def process_files_with_overlap_and_count(time_file, data_file):
    try:
        # 1번 파일 시간 읽기
        with open(time_file, 'r') as file:
            times = [float(line.strip()) for line in file.readlines()]

        # 2번 파일 (시간,값) 읽기
        data_entries = []
        with open(data_file, 'r') as file:
            for line in file:
                parts = line.strip().split(',')

                t = float(parts[0].strip())
                v = float(parts[1].strip())
                data_entries.append((t, v))

        # 시간 기준 정렬
        data_entries.sort(key=lambda x: x[0])

        # p2의 시간 범위
        data_start = data_entries[0][0]
        data_end   = data_entries[-1][0]

        # p1.txt 중에서 겹치는 시간만
        relevant_times = [t for t in times if data_start <= t <= data_end]

        if len(relevant_times) < 2:
            print("Not enough overlapping time intervals.")
            return

        # 구간별 카운트 (구간 개수 = relevant_times - 1)
        anomaly_counts = [0] * (len(relevant_times) - 1)
        total_counts   = [0] * (len(relevant_times) - 1)

        rt_index = 0  # 현재 구간 위치

        # ===============================
        #      시계열 전체 스캔
        # ===============================
        for t, v in data_entries:

            # t가 어느 구간에 속하는지 찾기
            while rt_index < len(relevant_times) - 1 and t >= relevant_times[rt_index + 1]:
                rt_index += 1

            if rt_index >= len(relevant_times) - 1:
                break

            # 전체 카운트 증가
            total_counts[rt_index] += 1

            # 이상치 판단 (단순 version)
            if v >= 2:        # 1 = 정상, 2 이상 = anomaly
                anomaly_counts[rt_index] += 1

        # ===============================
        #      결과 저장
        # ===============================
        transition_info = []

        for i in range(len(relevant_times) - 1):
            t_start = relevant_times[i]
            b1c = anomaly_counts[i]
            b1t = total_counts[i]
            transition_info.append((t_start, b1c, b1t))

        # 새 카운트 체계: 0~4, 5+
        b1c_count = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, "5+": 0}

        total = 0
        hit = 0

        with open('result.txt', 'w') as f:
            for t1, b1c, b1t in transition_info:
                f.write(f"{int(t1)}, {b1c}/{b1t}\n")

                if b1t == 0:
                    continue

                total += 1
                if b1c >= 1:
                    hit += 1

                # 분류
                if b1c <= 4:
                    b1c_count[b1c] += 1
                else:
                    b1c_count["5+"] += 1

        # summary 출력
        print("\n======== Summary ========")
        print(f"Total               : {hit}/{total}")
        for k in [0, 1, 2, 3, 4]:
            print(f"misprediction = {k}   : {b1c_count[k]}")
        print(f"misprediction >= 5  : {b1c_count['5+']}")
        print(f"ratio               : {hit / total * 100:.2f}%")

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()



# 사용 예시
time_file = 'p1.txt'
data_file = 'p2.txt'
process_files_with_overlap_and_count(time_file, data_file)
