from collections import Counter
import traceback

def count_value_distribution(data_file):
    try:
        counts = Counter()

        with open(data_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                parts = line.split(',')
                if len(parts) < 2:
                    continue  # 포맷 이상한 줄 스킵

                # time 은 버리고 value만 사용
                v_str = parts[1].strip()
                try:
                    v = int(float(v_str))  # "1.0" 같은 것도 처리되게
                except ValueError:
                    # 숫자 아니면 스킵
                    continue

                counts[v] += 1

        # 전체 요약 출력
        print("===== Value distribution =====")
        # value 오름차순으로 정렬해서 출력
        for v in sorted(counts.keys()):
            print(f"value = {v}: {counts[v]} times")

        # 특히 1, 2에 관심 있을 때
        print("\n----- Focus on 1 and 2 -----")
        print(f"value = 1: {counts.get(1, 0)} times")
        print(f"value = 2: {counts.get(2, 0)} times")

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()


# 사용 예시
data_file = "p2.txt"
count_value_distribution(data_file)
