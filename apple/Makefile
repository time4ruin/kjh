conjuring: conjuring_apple.c
	clang -O0 -S conjuring_apple.c -o conjuring.s
	clang -O0 -arch x86_64 conjuring.c -o test.bin -lm -Wl,-no_pie

clean:
	rm -f test.bin