conjuring_aarch64: conjuring_aarch64.c
	aarch64-linux-gnu-gcc -march=armv8-a conjuring_aarch64.c -o test.out -static -lm

conjuring_x86: conjuring_x86.c
	gcc conjuring_x86.c -o test.out -lm

clean:
	rm -f test.out attack.out