	.arch armv8-a
	.file	"p2.c"
	.text
	.align	2
	.global	mean
	.type	mean, %function
mean:
.LFB6:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	x0, [sp, 8]
	str	w1, [sp, 4]
	str	w2, [sp]
	str	xzr, [sp, 24]
	ldr	w0, [sp, 4]
	str	w0, [sp, 20]
	b	.L2
.L3:
	ldrsw	x0, [sp, 20]
	lsl	x0, x0, 2
	ldr	x1, [sp, 8]
	add	x0, x1, x0
	ldr	w0, [x0]
	sxtw	x0, w0
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	str	x0, [sp, 24]
	ldr	w0, [sp, 20]
	add	w0, w0, 1
	str	w0, [sp, 20]
.L2:
	ldr	w1, [sp, 20]
	ldr	w0, [sp]
	cmp	w1, w0
	blt	.L3
	ldr	w1, [sp]
	ldr	w0, [sp, 4]
	sub	w0, w1, w0
	sxtw	x0, w0
	ldr	x1, [sp, 24]
	sdiv	x0, x1, x0
	add	sp, sp, 32
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	mean, .-mean
	.section	.rodata
	.align	3
.LC0:
	.string	"Window %d-%d: Mean = %d\n"
	.align	3
.LC1:
	.string	"Noise detected between Window %d and %d (Mean Diff = %d)\n"
	.text
	.align	2
	.global	detect_noise
	.type	detect_noise, %function
detect_noise:
.LFB7:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	str	x19, [sp, 16]
	.cfi_offset 19, -80
	str	x0, [sp, 56]
	str	w1, [sp, 52]
	str	w2, [sp, 48]
	str	w3, [sp, 44]
	ldr	w1, [sp, 52]
	ldr	w0, [sp, 48]
	sdiv	w0, w1, w0
	str	w0, [sp, 72]
	ldrsw	x0, [sp, 72]
	lsl	x0, x0, 2
	bl	malloc
	str	x0, [sp, 88]
	str	wzr, [sp, 64]
	b	.L6
.L7:
	ldr	w1, [sp, 64]
	ldr	w0, [sp, 48]
	mul	w0, w1, w0
	str	w0, [sp, 80]
	ldr	w1, [sp, 80]
	ldr	w0, [sp, 48]
	add	w0, w1, w0
	str	w0, [sp, 84]
	ldrsw	x0, [sp, 64]
	lsl	x0, x0, 2
	ldr	x1, [sp, 88]
	add	x19, x1, x0
	ldr	w2, [sp, 84]
	ldr	w1, [sp, 80]
	ldr	x0, [sp, 56]
	bl	mean
	str	w0, [x19]
	ldr	w0, [sp, 84]
	sub	w2, w0, #1
	ldrsw	x0, [sp, 64]
	lsl	x0, x0, 2
	ldr	x1, [sp, 88]
	add	x0, x1, x0
	ldr	w0, [x0]
	mov	w3, w0
	ldr	w1, [sp, 80]
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	printf
	ldr	w0, [sp, 64]
	add	w0, w0, 1
	str	w0, [sp, 64]
.L6:
	ldr	w1, [sp, 64]
	ldr	w0, [sp, 72]
	cmp	w1, w0
	blt	.L7
	mov	w0, 1
	str	w0, [sp, 68]
	b	.L8
.L10:
	ldrsw	x0, [sp, 68]
	lsl	x0, x0, 2
	ldr	x1, [sp, 88]
	add	x0, x1, x0
	ldr	w1, [x0]
	ldrsw	x0, [sp, 68]
	lsl	x0, x0, 2
	sub	x0, x0, #4
	ldr	x2, [sp, 88]
	add	x0, x2, x0
	ldr	w0, [x0]
	sub	w0, w1, w0
	cmp	w0, 0
	csneg	w0, w0, w0, ge
	str	w0, [sp, 76]
	ldr	w1, [sp, 76]
	ldr	w0, [sp, 44]
	cmp	w1, w0
	ble	.L9
	ldr	w0, [sp, 68]
	sub	w0, w0, #1
	ldr	w3, [sp, 76]
	ldr	w2, [sp, 68]
	mov	w1, w0
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printf
.L9:
	ldr	w0, [sp, 68]
	add	w0, w0, 1
	str	w0, [sp, 68]
.L8:
	ldr	w1, [sp, 68]
	ldr	w0, [sp, 72]
	cmp	w1, w0
	blt	.L10
	ldr	x0, [sp, 88]
	bl	free
	nop
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE7:
	.size	detect_noise, .-detect_noise
	.align	2
	.global	compare_desc
	.type	compare_desc, %function
compare_desc:
.LFB8:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	x0, [sp, 8]
	str	x1, [sp]
	ldr	x0, [sp]
	ldr	w1, [x0, 8]
	ldr	x0, [sp, 8]
	ldr	w0, [x0, 8]
	sub	w0, w1, w0
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE8:
	.size	compare_desc, .-compare_desc
	.section	.rodata
	.align	3
.LC2:
	.string	"=== %s ===\n"
	.align	3
.LC3:
	.string	"%lu: %d\n"
	.text
	.align	2
	.global	print_histogram
	.type	print_histogram, %function
print_histogram:
.LFB9:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	str	x0, [sp, 40]
	str	w1, [sp, 36]
	str	x2, [sp, 24]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 4
	bl	malloc
	str	x0, [sp, 80]
	str	wzr, [sp, 60]
	str	wzr, [sp, 64]
	b	.L14
.L20:
	ldrsw	x0, [sp, 64]
	lsl	x0, x0, 3
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	ldr	x0, [x0]
	str	x0, [sp, 88]
	str	wzr, [sp, 68]
	str	wzr, [sp, 72]
	b	.L15
.L18:
	ldrsw	x0, [sp, 72]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	ldr	x0, [x0]
	ldr	x1, [sp, 88]
	cmp	x1, x0
	bne	.L16
	ldrsw	x0, [sp, 72]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	ldr	w1, [x0, 8]
	add	w1, w1, 1
	str	w1, [x0, 8]
	mov	w0, 1
	str	w0, [sp, 68]
	b	.L17
.L16:
	ldr	w0, [sp, 72]
	add	w0, w0, 1
	str	w0, [sp, 72]
.L15:
	ldr	w1, [sp, 72]
	ldr	w0, [sp, 60]
	cmp	w1, w0
	blt	.L18
.L17:
	ldr	w0, [sp, 68]
	cmp	w0, 0
	bne	.L19
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	ldr	x1, [sp, 88]
	str	x1, [x0]
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	mov	w1, 1
	str	w1, [x0, 8]
	ldr	w0, [sp, 60]
	add	w0, w0, 1
	str	w0, [sp, 60]
.L19:
	ldr	w0, [sp, 64]
	add	w0, w0, 1
	str	w0, [sp, 64]
.L14:
	ldr	w1, [sp, 64]
	ldr	w0, [sp, 36]
	cmp	w1, w0
	blt	.L20
	ldrsw	x1, [sp, 60]
	adrp	x0, compare_desc
	add	x3, x0, :lo12:compare_desc
	mov	x2, 16
	ldr	x0, [sp, 80]
	bl	qsort
	ldr	x1, [sp, 24]
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printf
	str	wzr, [sp, 76]
	b	.L21
.L22:
	ldrsw	x0, [sp, 76]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	ldr	x3, [x0]
	ldrsw	x0, [sp, 76]
	lsl	x0, x0, 4
	ldr	x1, [sp, 80]
	add	x0, x1, x0
	ldr	w0, [x0, 8]
	mov	w2, w0
	mov	x1, x3
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	printf
	ldr	w0, [sp, 76]
	add	w0, w0, 1
	str	w0, [sp, 76]
.L21:
	ldr	w1, [sp, 76]
	ldr	w0, [sp, 60]
	cmp	w1, w0
	blt	.L22
	mov	w0, 10
	bl	putchar
	ldr	x0, [sp, 80]
	bl	free
	nop
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE9:
	.size	print_histogram, .-print_histogram
	.align	2
	.global	func1
	.type	func1, %function
func1:
.LFB10:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp
	str	w0, [sp, 28]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 72]
	mov	x1, 0
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	w0, [sp, 28]
	cmp	w0, 0
	beq	.L24
#APP
// 12 "p2.c" 1
	.rept 10000
	nop
	.endr
	
// 0 "" 2
#NO_APP
	b	.L25
.L24:
#APP
// 19 "p2.c" 1
	.rept 9999
	nop
	.endr
	
// 0 "" 2
#NO_APP
.L25:
	add	x0, sp, 56
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	x0, [sp, 56]
	mov	w1, w0
	ldr	x0, [sp, 40]
	sub	w1, w1, w0
	ldr	x0, [sp, 64]
	mov	w2, w0
	ldr	x0, [sp, 48]
	sub	w0, w2, w0
	add	w0, w1, w0
	str	w0, [sp, 36]
	ldr	w0, [sp, 36]
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 72]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L27
	bl	__stack_chk_fail
.L27:
	mov	w0, w1
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE10:
	.size	func1, .-func1
	.align	2
	.global	dummy
	.type	dummy, %function
dummy:
.LFB11:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x0, 0
	bl	time
	bl	srand
	bl	rand
	mov	w0, 1
	bl	sleep
	nop
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE11:
	.size	dummy, .-dummy
	.section	.rodata
	.align	3
.LC4:
	.string	"[Spy] address of func1: %p\n"
	.align	3
.LC5:
	.string	"w"
	.align	3
.LC6:
	.string	"p2.txt"
	.align	3
.LC7:
	.string	"%lld,%d\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB12:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 72]
	mov	x1, 0
	mov	w0, 3
	str	w0, [sp, 16]
	adrp	x0, func1
	add	x1, x0, :lo12:func1
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	printf
	add	x0, sp, 56
	mov	x1, x0
	mov	w0, 0
	bl	clock_gettime
	adrp	x0, .LC5
	add	x1, x0, :lo12:.LC5
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	fopen
	str	x0, [sp, 24]
.L30:
#APP
// 47 "p2.c" 1
	dmb sy
// 0 "" 2
#NO_APP
	mov	w0, 0
	bl	func1
	str	w0, [sp, 20]
#APP
// 49 "p2.c" 1
	dmb sy
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 0
	bl	clock_gettime
	ldr	x1, [sp, 40]
	mov	x0, 51712
	movk	x0, 0x3b9a, lsl 16
	mul	x1, x1, x0
	ldr	x0, [sp, 48]
	add	x0, x1, x0
	str	x0, [sp, 32]
	ldr	w3, [sp, 20]
	ldr	x2, [sp, 32]
	adrp	x0, .LC7
	add	x1, x0, :lo12:.LC7
	ldr	x0, [sp, 24]
	bl	fprintf
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 56]
	sub	x1, x1, x0
	ldrsw	x0, [sp, 16]
	cmp	x1, x0
	blt	.L30
	ldr	x0, [sp, 24]
	bl	fclose
	mov	w0, 0
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 72]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L32
	bl	__stack_chk_fail
.L32:
	mov	w0, w1
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE12:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
