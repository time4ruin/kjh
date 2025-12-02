	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	dummy
	.type	dummy, %function
dummy:
.LFB0:
	.cfi_startproc
#APP
// 8 "branches.c" 1
	.rept 34
	nop
	.endr
	
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE0:
	.size	dummy, .-dummy
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB1:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 64
	str	w0, [sp, 12]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 56]
	mov	x1, 0
#APP
// 15 "branches.c" 1
	dsb sy
// 0 "" 2
// 16 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 24
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 18 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 20 "branches.c" 1
	.global branch1_eq_label  
	.global branch1_else      
	cmp    w0, #0      
	branch1_eq_label:         
	b.eq   branch1_else       
	branch1_if:               
	.rept 8000                
	nop                       
	.endr                     
	b     branch1_end         
	branch1_else:             
	.rept 8000                
	nop                       
	.endr                     
	branch1_end:              
	
// 0 "" 2
// 41 "branches.c" 1
	dsb sy
// 0 "" 2
// 42 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 44 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 24]
	sub	x0, x1, x0
	mov	x2, x0
	ldr	x1, [sp, 48]
	ldr	x0, [sp, 32]
	sub	x0, x1, x0
	add	x0, x2, x0
	str	x0, [sp, 16]
	ldr	x0, [sp, 16]
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 56]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L4
	bl	__stack_chk_fail
.L4:
	mov	x0, x1
	ldp	x29, x30, [sp, 64]
	add	sp, sp, 80
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	branch1, .-branch1
	.align	2
	.global	branch2
	.type	branch2, %function
branch2:
.LFB2:
	.cfi_startproc
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 64
	str	w0, [sp, 12]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 56]
	mov	x1, 0
#APP
// 51 "branches.c" 1
	.rept 10
	nop
	.endr
	
// 0 "" 2
// 53 "branches.c" 1
	dsb sy
// 0 "" 2
// 54 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 24
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 56 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 58 "branches.c" 1
	.global branch2_eq_label  
	cmp    w0, #0      
	branch2_eq_label:         
	b.eq   branch2_else       
	branch2_if:               
	.rept 8000                
	nop                       
	.endr                     
	b     branch2_end         
	branch2_else:             
	.rept 8000                
	nop                       
	.endr                     
	branch2_end:              
	
// 0 "" 2
// 78 "branches.c" 1
	dsb sy
// 0 "" 2
// 79 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 81 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 24]
	sub	x0, x1, x0
	mov	x2, x0
	ldr	x1, [sp, 48]
	ldr	x0, [sp, 32]
	sub	x0, x1, x0
	add	x0, x2, x0
	str	x0, [sp, 16]
	ldr	x0, [sp, 16]
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 56]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L7
	bl	__stack_chk_fail
.L7:
	mov	x0, x1
	ldp	x29, x30, [sp, 64]
	add	sp, sp, 80
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE2:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
