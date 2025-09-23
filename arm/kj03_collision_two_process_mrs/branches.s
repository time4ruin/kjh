	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	w0, [sp, 12]
#APP
// 8 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 9 "branches.c" 1
	dsb sy
// 0 "" 2
// 10 "branches.c" 1
	isb
// 0 "" 2
// 11 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 16]
#APP
// 12 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
	cmp	w0, 0
	beq	.L2
#APP
// 15 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
	b	.L3
.L2:
#APP
// 19 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
.L3:
#APP
// 21 "branches.c" 1
	dsb sy
// 0 "" 2
// 22 "branches.c" 1
	isb
// 0 "" 2
// 23 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 24]
#APP
// 24 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 24]
	ldr	x0, [sp, 16]
	sub	x0, x1, x0
	add	sp, sp, 32
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	branch1, .-branch1
	.align	2
	.global	dummy_001
	.type	dummy_001, %function
dummy_001:
.LFB1:
	.cfi_startproc
#APP
// 30 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 31 "branches.c" 1
	nop
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE1:
	.size	dummy_001, .-dummy_001
	.align	2
	.global	dummy_002
	.type	dummy_002, %function
dummy_002:
.LFB2:
	.cfi_startproc
#APP
// 35 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 36 "branches.c" 1
	nop
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE2:
	.size	dummy_002, .-dummy_002
	.align	2
	.global	branch2
	.type	branch2, %function
branch2:
.LFB3:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp
	str	w0, [sp, 28]
#APP
// 42 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 43 "branches.c" 1
	dmb sy
// 0 "" 2
// 44 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 32]
#APP
// 45 "branches.c" 1
	dmb sy
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 28]
	cmp	w0, 0
	beq	.L8
	mov	x0, 100
	bl	delay
	b	.L9
.L8:
	mov	x0, 100
	bl	delay
.L9:
#APP
// 56 "branches.c" 1
	dmb sy
// 0 "" 2
// 57 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 40]
#APP
// 58 "branches.c" 1
	dmb sy
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 32]
	sub	x0, x1, x0
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE3:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
