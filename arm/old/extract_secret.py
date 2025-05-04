import numpy as np

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
                if len(parts) == 2:
                    time = float(parts[0].strip())
                    value = float(parts[1].strip())
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

        # Large values 총 개수
        total_large_values = 0
        total = 0

        # 시간 간격 처리 및 데이터 분석
        for i in range(len(relevant_times) - 1):
            start_time = relevant_times[i]
            end_time = relevant_times[i + 1]

            # 해당 시간 구간에 속하는 데이터 필터링
            relevant_data = [value for time, value in data_entries if start_time <= time < end_time]
            total += 1

            if relevant_data:
                # 평균 계산
                mean_value = np.mean(relevant_data)

                # 평균보다 threshold 배 이상 큰 값 확인
                large_values = [value for value in relevant_data if value > mean_value * threshold]
                if large_values:
                    total_large_values += 1 # 총 개수 추가

                # if large_values:
                #     print(f"Between {start_time} and {end_time}, large values found: {large_values}")
                # else:
                #     print(f"Between {start_time} and {end_time}, no large values found.")
            else:
                print(f"Between {start_time} and {end_time}, no data available.")

        # 총 large values 출력
        print(f"\nTotal large values: {total_large_values}/{total}")

    except Exception as e:
        print(f"Error: {e}")

# 사용 예시
time_file = 'p1.txt'
data_file = 'p2.txt'
process_files_with_overlap_and_count(time_file, data_file, threshold=2.0)
