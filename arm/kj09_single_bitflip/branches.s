	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	dummy1
	.type	dummy1, %function
dummy1:
.LFB0:
	.cfi_startproc
	nop
	ret
	.cfi_endproc
.LFE0:
	.size	dummy1, .-dummy1
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB1:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	w0, [sp, 12]
#APP
// 19 "branches.c" 1
	dsb sy
// 0 "" 2
// 20 "branches.c" 1
	isb
// 0 "" 2
// 21 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 16]
#APP
// 22 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 24 "branches.c" 1
	.global branch1_eq_label  
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
// 44 "branches.c" 1
	dsb sy
// 0 "" 2
// 45 "branches.c" 1
	isb
// 0 "" 2
// 46 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 24]
#APP
// 47 "branches.c" 1
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
.LFE1:
	.size	branch1, .-branch1
	.align	2
	.global	dummy2
	.type	dummy2, %function
dummy2:
.LFB2:
	.cfi_startproc
	nop
	ret
	.cfi_endproc
.LFE2:
	.size	dummy2, .-dummy2
	.align	2
	.global	branch2
	.type	branch2, %function
branch2:
.LFB3:
	.cfi_startproc
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	w0, [sp, 12]
#APP
// 67 "branches.c" 1
	dsb sy
// 0 "" 2
// 68 "branches.c" 1
	isb
// 0 "" 2
// 69 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 16]
#APP
// 70 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 72 "branches.c" 1
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
// 92 "branches.c" 1
	dsb sy
// 0 "" 2
// 93 "branches.c" 1
	isb
// 0 "" 2
// 94 "branches.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 24]
#APP
// 95 "branches.c" 1
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
.LFE3:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
