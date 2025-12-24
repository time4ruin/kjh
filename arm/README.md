윈도우 VSCode + WSL에서 윈도우 adb 심볼릭 링크 만들어서 사용하는 법
alias adbwin="/mnt/c/Users/time4/platform-tools/adb.exe"
source ~/.bashrc


aarch64 크로스 컴파일한 바이너리 디버깅하는 방법
gdb-multiarch


# Tip (~/.bashrc)
alias adbwin="/mnt/c/Users/time4/platform-tools/adb.exe"
adbtest() {
    if [ $# -lt 1 ]; then
        echo "Usage: adbtest <cpu_id>"
        echo "Example: adbtest 6"
        return 1
    fi

    local CPU=$1
    local SRC=./test.bin
    local DST=/data/local/tmp/test.bin

    echo "[+] Pushing $SRC → $DST ..."
    adbwin push "$SRC" "$DST" >/dev/null || { echo "push failed"; return 1; }

    echo "[+] Setting executable permission ..."
    adbwin shell chmod +x "$DST" || { echo "chmod failed"; return 1; }

    echo "[+] Running on CPU $CPU ..."
    adbwin shell "taskset $CPU $DST"
}

# 스케줄러 우선순위 조정
chrt -f 99 taskset 1 ./test.bin (루트권한이어야 함)
