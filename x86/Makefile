nested:
	gcc -no-pie p1_nested.c -o p1_nested.bin -lm
	gcc -no-pie p2_nested.c -o p2_nested.bin -lm

single:
	gcc -no-pie p1.c -o p1.bin -lm
	gcc -no-pie p2.c -o p2.bin -lm

asm: conjuring_x86.c
	gcc -S -no-pie conjuring_x86.c -o test.s

bin: test.s
	as test.s -o test.o
	ld test.o -o test.bin -lm

attack_x86: attack_x86.c
	gcc attack_x86.c -o test.bin -lm

conjuring_x86: conjuring_x86.c
	gcc -no-pie conjuring_x86.c -o test.bin -lm

clean:
	rm -f test.bin attack.bin