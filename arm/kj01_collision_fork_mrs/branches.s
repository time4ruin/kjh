	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	inner
	.type	inner, %function
inner:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, 12]
	ldr	w0, [sp, 12]
	cmp	w0, 0
	beq	.L2
#APP
// 9 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
#NO_APP
	b	.L4
.L2:
#APP
// 16 "branches.c" 1
	.rept 8000
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
.LFE0:
	.size	inner, .-inner
	.align	2
	.global	outer
	.type	outer, %function
outer:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	w0, [sp, 28]
	str	w1, [sp, 24]
	str	w2, [sp, 20]
	ldr	w0, [sp, 28]
	cmp	w0, 0
	beq	.L6
#APP
// 27 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 20]
	cmp	w0, 0
	beq	.L7
	mov	x0, 10000
	bl	delay
.L7:
	ldr	w0, [sp, 20]
	cmp	w0, 0
	beq	.L10
	ldr	w0, [sp, 24]
	bl	inner
	b	.L10
.L6:
#APP
// 33 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
.L10:
	nop
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	outer, .-outer
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
