import pandas as pd

# 파일 읽기
df = pd.read_csv("p2.txt", header=None, names=["timestamp", "latency"])

# 1열 간 차이 계산
df["delta"] = df["timestamp"].diff().fillna(0).astype(int)

# 출력: 쉼표 + 공백 형식
with open("p2_with_delta.txt", "w") as f:
    for _, row in df.iterrows():
        f.write(f"{row['timestamp']}, {row['latency']}, {row['delta']}\n")
