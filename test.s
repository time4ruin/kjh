	.file	"conjuring_x86.c"
	.text
	.globl	mean
	.type	mean, @function
mean:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	%esi, -28(%rbp)
	movl	%edx, -32(%rbp)
	movq	$0, -8(%rbp)
	movl	-28(%rbp), %eax
	movl	%eax, -12(%rbp)
	jmp	.L2
.L3:
	movl	-12(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	cltq
	addq	%rax, -8(%rbp)
	addl	$1, -12(%rbp)
.L2:
	movl	-12(%rbp), %eax
	cmpl	-32(%rbp), %eax
	jl	.L3
	movl	-32(%rbp), %eax
	subl	-28(%rbp), %eax
	movslq	%eax, %rcx
	movq	-8(%rbp), %rax
	cqto
	idivq	%rcx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	mean, .-mean
	.section	.rodata
.LC0:
	.string	"Window %d-%d: Mean = %d\n"
	.align 8
.LC1:
	.string	"Noise detected between Window %d and %d (Mean Diff = %d)\n"
	.text
	.globl	detect_noise
	.type	detect_noise, @function
detect_noise:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$72, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -56(%rbp)
	movl	%esi, -60(%rbp)
	movl	%edx, -64(%rbp)
	movl	%ecx, -68(%rbp)
	movl	-60(%rbp), %eax
	cltd
	idivl	-64(%rbp)
	movl	%eax, -40(%rbp)
	movl	-40(%rbp), %eax
	cltq
	salq	$2, %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -24(%rbp)
	movl	$0, -48(%rbp)
	jmp	.L6
.L7:
	movl	-48(%rbp), %eax
	imull	-64(%rbp), %eax
	movl	%eax, -32(%rbp)
	movl	-32(%rbp), %edx
	movl	-64(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -28(%rbp)
	movl	-48(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	leaq	(%rdx,%rax), %rbx
	movl	-28(%rbp), %edx
	movl	-32(%rbp), %ecx
	movq	-56(%rbp), %rax
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	mean
	movl	%eax, (%rbx)
	movl	-48(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movl	-28(%rbp), %eax
	leal	-1(%rax), %esi
	movl	-32(%rbp), %eax
	movl	%edx, %ecx
	movl	%esi, %edx
	movl	%eax, %esi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -48(%rbp)
.L6:
	movl	-48(%rbp), %eax
	cmpl	-40(%rbp), %eax
	jl	.L7
	movl	$1, -44(%rbp)
	jmp	.L8
.L10:
	movl	-44(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movl	-44(%rbp), %eax
	cltq
	salq	$2, %rax
	leaq	-4(%rax), %rcx
	movq	-24(%rbp), %rax
	addq	%rcx, %rax
	movl	(%rax), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	sarl	$31, %eax
	xorl	%eax, %edx
	movl	%edx, -36(%rbp)
	subl	%eax, -36(%rbp)
	movl	-36(%rbp), %eax
	cmpl	-68(%rbp), %eax
	jle	.L9
	movl	-44(%rbp), %eax
	leal	-1(%rax), %esi
	movl	-36(%rbp), %edx
	movl	-44(%rbp), %eax
	movl	%edx, %ecx
	movl	%eax, %edx
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L9:
	addl	$1, -44(%rbp)
.L8:
	movl	-44(%rbp), %eax
	cmpl	-40(%rbp), %eax
	jl	.L10
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	nop
	addq	$72, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	detect_noise, .-detect_noise
	.globl	rdtsc
	.type	rdtsc, @function
rdtsc:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
#APP
# 43 "./utils.c" 1
	mfence
# 0 "" 2
# 44 "./utils.c" 1
	rdtsc
# 0 "" 2
#NO_APP
	movq	%rax, -16(%rbp)
	movq	%rdx, -8(%rbp)
	movq	-8(%rbp), %rax
	salq	$32, %rax
	orq	%rax, -16(%rbp)
#APP
# 46 "./utils.c" 1
	mfence
# 0 "" 2
#NO_APP
	movq	-16(%rbp), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	rdtsc, .-rdtsc
	.globl	flush
	.type	flush, @function
flush:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rdx
	movq	%rdx, %rcx
#APP
# 50 "./utils.c" 1
	clflush 0(%rcx)

# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	flush, .-flush
	.globl	maccess
	.type	maccess, @function
maccess:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rdx
	movq	%rdx, %rcx
#APP
# 51 "./utils.c" 1
	movq (%rcx), %rax

# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	maccess, .-maccess
	.globl	mfence
	.type	mfence, @function
mfence:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
#APP
# 52 "./utils.c" 1
	mfence
# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	mfence, .-mfence
	.globl	func1
	.type	func1, @function
func1:
.LFB12:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	cmpl	$0, -4(%rbp)
	je	.L18
#APP
# 9 "conjuring_x86.c" 1
	.rept 10000
	nop
	.endr
	
# 0 "" 2
#NO_APP
.L18:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	func1, .-func1
	.globl	func2
	.type	func2, @function
func2:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	cmpl	$0, -4(%rbp)
	je	.L21
#APP
# 19 "conjuring_x86.c" 1
	.rept 10000
	nop
	.endr
	
# 0 "" 2
#NO_APP
.L21:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	func2, .-func2
	.globl	func3
	.type	func3, @function
func3:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	cmpl	$0, -4(%rbp)
	je	.L25
#APP
# 29 "conjuring_x86.c" 1
	.rept 10000
	nop
	.endr
	
# 0 "" 2
#NO_APP
	cmpl	$0, -8(%rbp)
	je	.L24
#APP
# 35 "conjuring_x86.c" 1
	.rept 10000
	nop
	.endr
	
# 0 "" 2
#NO_APP
	jmp	.L25
.L24:
#APP
# 42 "conjuring_x86.c" 1
	.rept 1
	nop
	.endr
	
# 0 "" 2
#NO_APP
.L25:
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	func3, .-func3
	.section	.rodata
.LC2:
	.string	"address of func1: %p"
.LC3:
	.string	"address of func2: %p"
.LC4:
	.string	"w"
.LC5:
	.string	"conjuring.txt"
.LC6:
	.string	"%d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$80, %rsp
	movl	$10000, -60(%rbp)
	movl	-60(%rbp), %eax
	cltq
	salq	$2, %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -48(%rbp)
	movl	-60(%rbp), %eax
	cltq
	salq	$2, %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -40(%rbp)
	movl	-60(%rbp), %eax
	cltq
	salq	$2, %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, -32(%rbp)
	leaq	func1(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	func2(%rip), %rsi
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, -76(%rbp)
	jmp	.L27
.L28:
	movl	$1, %edi
	call	func1
	movl	$0, %eax
	call	rdtsc
	movq	%rax, -16(%rbp)
	movl	$1, %edi
	call	func2
	movl	$0, %eax
	call	rdtsc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	%eax, %edx
	movq	-16(%rbp), %rax
	subl	%eax, %edx
	movl	-76(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	movq	-48(%rbp), %rax
	addq	%rcx, %rax
	movl	%edx, (%rax)
	addl	$1, -76(%rbp)
.L27:
	movl	-76(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L28
	movl	$0, -72(%rbp)
	jmp	.L29
.L30:
	movl	$0, %edi
	call	func1
	movl	$0, %eax
	call	rdtsc
	movq	%rax, -16(%rbp)
	movl	$1, %edi
	call	func2
	movl	$0, %eax
	call	rdtsc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	%eax, %edx
	movq	-16(%rbp), %rax
	subl	%eax, %edx
	movl	-72(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	movq	-32(%rbp), %rax
	addq	%rcx, %rax
	movl	%edx, (%rax)
	addl	$1, -72(%rbp)
.L29:
	movl	-72(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L30
	movl	-60(%rbp), %eax
	movslq	%eax, %rdx
	imulq	$1717986919, %rdx, %rdx
	shrq	$32, %rdx
	sarl	$2, %edx
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -56(%rbp)
	movl	$100, -52(%rbp)
	movl	-52(%rbp), %ecx
	movl	-56(%rbp), %edx
	movl	-60(%rbp), %esi
	movq	-48(%rbp), %rax
	movq	%rax, %rdi
	call	detect_noise
	movl	-52(%rbp), %ecx
	movl	-56(%rbp), %edx
	movl	-60(%rbp), %esi
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	detect_noise
	leaq	.LC4(%rip), %rsi
	leaq	.LC5(%rip), %rdi
	call	fopen@PLT
	movq	%rax, -24(%rbp)
	movl	$0, -68(%rbp)
	jmp	.L31
.L32:
	movl	-68(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movq	-24(%rbp), %rax
	leaq	.LC6(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	addl	$1, -68(%rbp)
.L31:
	movl	-68(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L32
	movl	$0, -64(%rbp)
	jmp	.L33
.L34:
	movl	-64(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movq	-24(%rbp), %rax
	leaq	.LC6(%rip), %rsi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf@PLT
	addl	$1, -64(%rbp)
.L33:
	movl	-64(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L34
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	fclose@PLT
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
