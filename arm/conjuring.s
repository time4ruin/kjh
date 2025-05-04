	.arch armv8-a
	.file	"conjuring_armv8.c"
	.text
	.align	2
	.global	func
	.type	func, %function
func:
.LFB6:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, 12]
	ldr	w0, [sp, 12]
	cmp	w0, 0
	beq	.L2
#APP
// 12 "conjuring_armv8.c" 1
	.rept 10000
	nop
	.endr
	
// 0 "" 2
#NO_APP
	b	.L4
.L2:
#APP
// 19 "conjuring_armv8.c" 1
	.rept 10000
	nop
	.endr
	
// 0 "" 2
#NO_APP
.L4:
	nop
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	func, .-func
	.section	.rodata
	.align	3
.LC0:
	.string	"w"
	.align	3
.LC1:
	.string	"conjuring.txt"
	.align	3
.LC2:
	.string	"%d,%d\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB7:
	.cfi_startproc
	stp	x29, x30, [sp, -112]!
	.cfi_def_cfa_offset 112
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	mov	x29, sp
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 104]
	mov	x1, 0
	mov	w0, 1000
	str	w0, [sp, 36]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	bl	malloc
	str	x0, [sp, 48]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	bl	malloc
	str	x0, [sp, 56]
	str	wzr, [sp, 24]
	b	.L6
.L7:
	mov	w0, 0
	bl	func
	mov	w0, 0
	bl	func
	mov	w0, 0
	bl	func
	mov	w0, 0
	bl	func
	mov	w0, 0
	bl	func
	mov	w0, 0
	bl	func
	mov	w0, 1
	bl	func
	add	x0, sp, 72
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	str	w0, [sp, 44]
	mov	w0, 1
	bl	func
	add	x0, sp, 88
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	x0, [sp, 88]
	mov	w1, w0
	ldr	x0, [sp, 72]
	sub	w1, w1, w0
	ldr	x0, [sp, 96]
	mov	w2, w0
	ldr	x0, [sp, 80]
	sub	w0, w2, w0
	add	w2, w1, w0
	ldrsw	x0, [sp, 24]
	lsl	x0, x0, 2
	ldr	x1, [sp, 48]
	add	x0, x1, x0
	mov	w1, w2
	str	w1, [x0]
	ldr	w0, [sp, 24]
	add	w0, w0, 1
	str	w0, [sp, 24]
.L6:
	ldr	w1, [sp, 24]
	ldr	w0, [sp, 36]
	cmp	w1, w0
	blt	.L7
	str	wzr, [sp, 28]
	b	.L8
.L9:
	mov	w0, 0
	bl	func
	add	x0, sp, 72
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	str	w0, [sp, 40]
	mov	w0, 1
	bl	func
	add	x0, sp, 88
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	x0, [sp, 88]
	mov	w1, w0
	ldr	x0, [sp, 72]
	sub	w1, w1, w0
	ldr	x0, [sp, 96]
	mov	w2, w0
	ldr	x0, [sp, 80]
	sub	w0, w2, w0
	add	w2, w1, w0
	ldrsw	x0, [sp, 28]
	lsl	x0, x0, 2
	ldr	x1, [sp, 56]
	add	x0, x1, x0
	mov	w1, w2
	str	w1, [x0]
	ldr	w0, [sp, 28]
	add	w0, w0, 1
	str	w0, [sp, 28]
.L8:
	ldr	w1, [sp, 28]
	ldr	w0, [sp, 36]
	cmp	w1, w0
	blt	.L9
	adrp	x0, .LC0
	add	x1, x0, :lo12:.LC0
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	fopen
	str	x0, [sp, 64]
	str	wzr, [sp, 32]
	b	.L10
.L11:
	ldrsw	x0, [sp, 32]
	lsl	x0, x0, 2
	ldr	x1, [sp, 48]
	add	x0, x1, x0
	ldr	w2, [x0]
	ldrsw	x0, [sp, 32]
	lsl	x0, x0, 2
	ldr	x1, [sp, 56]
	add	x0, x1, x0
	ldr	w0, [x0]
	mov	w3, w0
	adrp	x0, .LC2
	add	x1, x0, :lo12:.LC2
	ldr	x0, [sp, 64]
	bl	fprintf
	ldr	w0, [sp, 32]
	add	w0, w0, 1
	str	w0, [sp, 32]
.L10:
	ldr	w1, [sp, 32]
	ldr	w0, [sp, 36]
	cmp	w1, w0
	blt	.L11
	ldr	x0, [sp, 64]
	bl	fclose
	mov	w0, 0
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 104]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L13
	bl	__stack_chk_fail
.L13:
	mov	w0, w1
	ldp	x29, x30, [sp], 112
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE7:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
