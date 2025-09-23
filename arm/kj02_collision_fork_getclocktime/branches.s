	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB0:
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
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 12 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 28]
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
#NO_APP
	add	x0, sp, 56
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 24 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 56]
	ldr	x0, [sp, 40]
	sub	x0, x1, x0
	mov	x2, x0
	ldr	x1, [sp, 64]
	ldr	x0, [sp, 48]
	sub	x0, x1, x0
	add	x0, x2, x0
	str	x0, [sp, 32]
	ldr	x0, [sp, 32]
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 72]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L5
	bl	__stack_chk_fail
.L5:
	mov	x0, x1
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
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
// 31 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 32 "branches.c" 1
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
// 36 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 37 "branches.c" 1
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
#APP
// 43 "branches.c" 1
	.p2align   14
	
// 0 "" 2
// 44 "branches.c" 1
	dsb sy
// 0 "" 2
// 45 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 47 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 28]
	cmp	w0, 0
	beq	.L9
#APP
// 50 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
	b	.L10
.L9:
#APP
// 54 "branches.c" 1
	.rept 8000
	 nop
	 .endr
	
// 0 "" 2
#NO_APP
.L10:
#APP
// 56 "branches.c" 1
	dsb sy
// 0 "" 2
// 57 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 56
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 59 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 56]
	ldr	x0, [sp, 40]
	sub	x0, x1, x0
	mov	x2, x0
	ldr	x1, [sp, 64]
	ldr	x0, [sp, 48]
	sub	x0, x1, x0
	add	x0, x2, x0
	str	x0, [sp, 32]
	ldr	x0, [sp, 32]
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 72]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L12
	bl	__stack_chk_fail
.L12:
	mov	x0, x1
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE3:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
