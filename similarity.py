from Levenshtein import distance
from dtw import accelerated_dtw
from sklearn.metrics import jaccard_score
import numpy as np

def similarity_levenshtein(str1, str2):
    dist = distance(str1, str2)
    max_len = max(len(str1), len(str2))
    similarity = 1 - (dist / max_len)  # 유사도 계산
    return similarity

def similarity_dtw(str1, str2):
    # 문자열을 숫자로 변환
    seq1 = np.array([int(c) for c in str1])
    seq2 = np.array([int(c) for c in str2])
    # DTW 거리 계산
    distance, _, _, _ = accelerated_dtw(seq1[:, None], seq2[:, None], dist='euclidean')
    max_len = max(len(seq1), len(seq2))
    similarity = 1 - (distance / max_len)  # 유사도 계산
    return similarity

# 예제
with open('output.txt', 'r') as file:
    str1 = file.readline().strip()
    str2 = file.readline().strip()
    
print(similarity_levenshtein(str1, str2))
print(similarity_dtw(str1, str2))