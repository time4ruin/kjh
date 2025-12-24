	.arch armv8-a
	.file	"victim.c"
	.text
	.align	2
	.global	branch
	.type	branch, %function
branch:
.LFB6:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, 12]
	ldr	w0, [sp, 12]
#APP
// 13 "victim.c" 1
	.global branch_eq_label  
	.global branch_else      
	cmp    w0, #0      
	branch_eq_label:         
	b.eq   branch_else       
	branch_if:               
	.rept 1                
	nop                       
	.endr                     
	b     branch_end         
	branch_else:             
	.rept 1                
	nop                       
	.endr                     
	nop                       
	branch_end:              
	
// 0 "" 2
#NO_APP
	nop
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	branch, .-branch
	.align	2
	.global	branch_nested
	.type	branch_nested, %function
branch_nested:
.LFB7:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, 12]
	str	w1, [sp, 8]
	ldr	w0, [sp, 12]
	ldr	w1, [sp, 8]
#APP
// 38 "victim.c" 1
	.rept 8000                                       
	nop                                             
	.endr                                           
	.global branch1_eq_label                        
	.global branch1_else                            
	cmp    w0, #0                               
	branch1_eq_label:                               
	b.eq   branch1_else                             
	branch1_if:                                     
	.rept 8000                                      
	nop                                             
	.endr                                           
	.rept 8000                                      
	nop                                             
	.endr                                           
	.rept 8000                                      
	nop                                             
	.endr                                           
	.rept 8000                                      
	nop                                             
	.endr                                           
	.global branch2_eq_label                        
	.global branch2_else                            
	cmp    w1, #0                               
	branch2_eq_label:                               
	b.eq   branch2_else                             
	branch2_if:                                     
	.rept 8000                                      
	nop                                             
	.endr                                           
	b      branch2_end                              
	branch2_else:                                   
	.rept 8000                                      
	nop                                             
	.endr                                           
	branch2_end:                                    
	b      branch1_end                              
	branch1_else:                                   
	.rept 8000                                      
	nop                                             
	.endr                                           
	branch1_end:                                    
	
// 0 "" 2
#NO_APP
	nop
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE7:
	.size	branch_nested, .-branch_nested
	.section	.rodata
	.align	3
.LC0:
	.string	"[VIC] address of single branch: %p\n"
	.align	3
.LC1:
	.string	"[VIC] address of outer branch: %p\n"
	.align	3
.LC2:
	.string	"[VIC] address of inner branch: %p\n"
	.align	3
.LC3:
	.string	"malloc failed"
	.align	3
.LC4:
	.string	"w"
	.align	3
.LC5:
	.string	"p1.txt"
	.align	3
.LC6:
	.string	"Loop ended at counter = %lu\n"
	.align	3
.LC7:
	.string	"%lu\n"
	.align	3
.LC8:
	.string	"Victim(Child) End"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB8:
	.cfi_startproc
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x29, x30, [sp, 112]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 112
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 104]
	mov	x1, 0
#APP
// 122 "victim.c" 1
	ldr    x2, =branch_eq_label
	ldr    x1, =branch1_eq_label
	ldr    x0, =branch2_eq_label
	
// 0 "" 2
#NO_APP
	str	x2, [sp, 16]
	str	x1, [sp, 24]
	str	x0, [sp, 32]
	ldr	x0, [sp, 16]
	mov	x1, x0
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	printf
	ldr	x0, [sp, 24]
	mov	x1, x0
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printf
	ldr	x0, [sp, 32]
	mov	x1, x0
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printf
	adrp	x0, :got:stdout
	ldr	x0, [x0, :got_lo12:stdout]
	ldr	x0, [x0]
	bl	fflush
	mov	x0, 23040
	movk	x0, 0x262, lsl 16
	bl	malloc
	str	x0, [sp, 40]
	ldr	x0, [sp, 40]
	cmp	x0, 0
	bne	.L4
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	perror
	mov	w0, 0
	b	.L5
.L4:
	str	wzr, [sp]
	adrp	x0, .LC4
	add	x1, x0, :lo12:.LC4
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	fopen
	str	x0, [sp, 48]
	str	xzr, [sp, 8]
	mov	x0, 1000
	str	x0, [sp, 56]
.L9:
	mov	x0, 38528
	movk	x0, 0x98, lsl 16
	bl	delay
	mov	w1, 1
	mov	w0, 1
	bl	branch_nested
#APP
// 159 "victim.c" 1
	dsb sy
// 0 "" 2
// 160 "victim.c" 1
	isb
// 0 "" 2
// 161 "victim.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 64]
#APP
// 162 "victim.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp]
	add	w1, w0, 1
	str	w1, [sp]
	sxtw	x0, w0
	lsl	x0, x0, 3
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	ldr	x1, [sp, 64]
	str	x1, [x0]
	ldr	x1, [sp, 8]
	ldr	x0, [sp, 56]
	sub	x0, x1, x0
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	lsr	x0, x0, 63
	str	x0, [sp, 80]
	adrp	x0, .L6
	add	x0, x0, :lo12:.L6
	str	x0, [sp, 88]
	adrp	x0, .L7
	add	x0, x0, :lo12:.L7
	str	x0, [sp, 96]
	ldr	x0, [sp, 80]
	lsl	x0, x0, 3
	add	x1, sp, 88
	ldr	x0, [x1, x0]
	nop
	br	x0
.L7:
	ldr	x0, [sp, 8]
	add	x0, x0, 1
	str	x0, [sp, 8]
	b	.L9
.L6:
	ldr	x1, [sp, 8]
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	printf
	str	wzr, [sp, 4]
	b	.L10
.L11:
	ldrsw	x0, [sp, 4]
	lsl	x0, x0, 3
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	ldr	x0, [x0]
	mov	x2, x0
	adrp	x0, .LC7
	add	x1, x0, :lo12:.LC7
	ldr	x0, [sp, 48]
	bl	fprintf
	ldr	w0, [sp, 4]
	add	w0, w0, 1
	str	w0, [sp, 4]
.L10:
	ldr	w1, [sp, 4]
	ldr	w0, [sp]
	cmp	w1, w0
	blt	.L11
	ldr	x0, [sp, 48]
	bl	fclose
	ldr	x0, [sp, 40]
	bl	free
	adrp	x0, .LC8
	add	x0, x0, :lo12:.LC8
	bl	puts
	mov	w0, 0
.L5:
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 104]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L12
	bl	__stack_chk_fail
.L12:
	mov	w0, w1
	ldp	x29, x30, [sp, 112]
	add	sp, sp, 128
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE8:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
