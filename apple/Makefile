conjuring: conjuring_apple.c
	clang -O0 -S conjuring_apple.c -o conjuring.s
	clang -O0 conjuring_apple.c -o test.bin
	# clang -O0 -arch x86_64 conjuring_apple.c -o test.bin -lm -Wl,-no_pie

single:
	clang -O0 -arch x86_64 p1.c -o p1.bin -lm -Wl,-no_pie
	clang -O0 -arch x86_64 p2.c -o p2.bin -lm -Wl,-no_pie
	lldb --batch -o "disassemble --name func1 --count 40" ./p1.bin | grep -E 'b[[:space:]]+0x'
	lldb --batch -o "disassemble --name func1 --count 40" ./p2.bin | grep -E 'b[[:space:]]+0x'

single_mrs: p1_mrs.c p2_mrs.c
	clang -O0 p1_mrs.c -o p1.bin
	clang -O0 p2_mrs.c -o p2.bin
	lldb --batch -o "disassemble --name func1 --count 40" ./p1.bin | grep -E 'b[[:space:]]+0x'
	lldb --batch -o "disassemble --name func1 --count 40" ./p2.bin | grep -E 'b[[:space:]]+0x'

afin: affinity_test.c
	clang -O0 affinity_test.c -o test.bin

fork: fork.c
	clang -O0 fork.c -o test.bin

fork_different: fork_differentbranch.c
	clang -O0 fork_differentbranch.c -o test.bin

fork_nested: fork_nested.c
	clang -O0 fork_nested.c -o test.bin
	
fork_nested_onlyb1: fork_nested_onlyb1.c
	clang -O0 fork_nested_onlyb1.c -o test.bin

spectre: spectre.c
	clang -O0 spectre.c -o test.bin

clean:
	rm -f *.bin