import matplotlib.pyplot as plt
import sys

def plot_with_offset(input_file, output_image):
    try:
        # 파일 읽기
        times = []
        values = []
        
        with open(input_file, 'r') as file:
            lines = file.readlines()
            if not lines:
                raise ValueError("The file is empty.")
            
            # 첫 번째 시간 값을 baseline으로 설정
            baseline_time = float(lines[0].strip().split(',')[0])
            
            for line in lines:
                parts = line.strip().split(',')
                if len(parts) == 2:
                    time = float(parts[0].strip()) - baseline_time  # 오프셋 계산
                    value = float(parts[1].strip())
                    times.append(time)
                    values.append(value)
        
        # 그래프 그리기
        plt.figure(figsize=(10, 6))
        plt.plot(times, values, marker='o', linestyle='-', color='b')
        plt.xlabel('Time (offset from baseline)')
        plt.ylabel('Value')
        plt.title('Time (Offset) vs Value')
        plt.grid(True)
        plt.tight_layout()
        
        # 이미지 파일로 저장
        plt.savefig(output_image)
        print(f"Graph saved as {output_image}")
    
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_with_offset.py <input_file> <output_image>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_image = sys.argv[2]
    plot_with_offset(input_file, output_image)
