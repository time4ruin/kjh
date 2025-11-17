conjuring: conjuring_armv8.c
	aarch64-linux-gnu-gcc -march=armv8-a -S conjuring_armv8.c -o conjuring.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static conjuring_armv8.c -o test -lm

single:
	aarch64-linux-gnu-gcc -march=armv8-a -S -static p1.c -o p1.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static p1.c -o p1 -lm
	aarch64-linux-gnu-gcc -march=armv8-a -S -static p2.c -o p2.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static p2.c -o p2 -lm

nested:
	aarch64-linux-gnu-gcc -march=armv8-a -S -static p1_nested.c -o p1_nested.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static p1_nested.c -o p1_nested -lm
	aarch64-linux-gnu-gcc -march=armv8-a -S -static p2_nested.c -o p2_nested.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static p2_nested.c -o p2_nested -lm
	aarch64-linux-gnu-gcc -march=armv8-a -S -static p2_nested_onlyb1.c -o p2_nested_onlyb1.s
	aarch64-linux-gnu-gcc -march=armv8-a -no-pie -static p2_nested_onlyb1.c -o p2_nested_onlyb1 -lm

tester:
	aarch64-linux-gnu-gcc -march=armv8-a -static single_tester.c -o single_tester -lm


clean:
	rm -f test.bin

# adb push test.bin /data/local/tmp
# adb pull /data/local/tmp/conjuring.txt