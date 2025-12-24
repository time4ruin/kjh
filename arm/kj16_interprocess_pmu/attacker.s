	.arch armv8-a
	.file	"attacker.c"
	.text
	.align	2
	.type	perf_event_open, %function
perf_event_open:
.LFB34:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp
	str	x0, [sp, 40]
	str	w1, [sp, 36]
	str	w2, [sp, 32]
	str	w3, [sp, 28]
	str	x4, [sp, 16]
	ldr	x5, [sp, 16]
	ldr	w4, [sp, 28]
	ldr	w3, [sp, 32]
	ldr	w2, [sp, 36]
	ldr	x1, [sp, 40]
	mov	x0, 241
	bl	syscall
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE34:
	.size	perf_event_open, .-perf_event_open
	.align	2
	.global	dummy1
	.type	dummy1, %function
dummy1:
.LFB35:
	.cfi_startproc
#APP
// 38 "attacker.c" 1
	.rept 7926
	nop
	.endr
	
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE35:
	.size	dummy1, .-dummy1
	.section	.rodata
	.align	3
.LC0:
	.string	"perf_event_open"
	.align	3
.LC1:
	.string	"ioctl RESET"
	.align	3
.LC2:
	.string	"ioctl ENABLE"
	.align	3
.LC3:
	.string	"ioctl DISABLE"
	.align	3
.LC4:
	.string	"read"
	.text
	.align	2
	.global	outer
	.type	outer, %function
outer:
.LFB36:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	x29, x30, [sp, 176]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 176
	str	w0, [sp, 12]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 168]
	mov	x1, 0
#APP
// 46 "attacker.c" 1
	.rept 10
	nop
	.endr
	
// 0 "" 2
#NO_APP
	add	x0, sp, 32
	mov	x2, 136
	mov	w1, 0
	bl	memset
	mov	w0, 7
	str	w0, [sp, 32]
	mov	w0, 136
	str	w0, [sp, 36]
	mov	x0, 16
	str	x0, [sp, 40]
	ldr	x0, [sp, 72]
	orr	x0, x0, 1
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	orr	x0, x0, 32
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	orr	x0, x0, 64
	str	x0, [sp, 72]
	add	x0, sp, 32
	mov	x4, 0
	mov	w3, -1
	mov	w2, -1
	mov	w1, 0
	bl	perf_event_open
	str	w0, [sp, 20]
	ldr	w0, [sp, 20]
	cmn	w0, #1
	bne	.L5
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	perror
	mov	x0, 0
	b	.L11
.L5:
	mov	w2, 0
	mov	x1, 9219
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L7
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	perror
.L7:
	mov	w2, 0
	mov	x1, 9216
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L8
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	perror
.L8:
#APP
// 77 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 80 "attacker.c" 1
	.global branch1_eq_label      
	cmp    w0, #0          
	branch1_eq_label:             
	b.eq   branch1_end            
	branch1_if:                   
	.rept 1                       
	nop                           
	.endr                         
	branch1_end:                  
	
// 0 "" 2
// 98 "attacker.c" 1
	dsb sy
// 0 "" 2
// 99 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	mov	w2, 0
	mov	x1, 9217
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L9
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	perror
.L9:
#APP
// 103 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	str	xzr, [sp, 24]
	add	x0, sp, 24
	mov	x2, 8
	mov	x1, x0
	ldr	w0, [sp, 20]
	bl	read
	cmp	x0, 8
	beq	.L10
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	perror
	str	xzr, [sp, 24]
.L10:
	ldr	w0, [sp, 20]
	bl	close
	ldr	x0, [sp, 24]
.L11:
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 168]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L12
	bl	__stack_chk_fail
.L12:
	mov	x0, x1
	ldp	x29, x30, [sp, 176]
	add	sp, sp, 192
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE36:
	.size	outer, .-outer
	.align	2
	.global	dummy2
	.type	dummy2, %function
dummy2:
.LFB37:
	.cfi_startproc
#APP
// 118 "attacker.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 119 "attacker.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 120 "attacker.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 121 "attacker.c" 1
	.rept 7884
	nop
	.endr
	
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE37:
	.size	dummy2, .-dummy2
	.align	2
	.global	inner
	.type	inner, %function
inner:
.LFB38:
	.cfi_startproc
	sub	sp, sp, #192
	.cfi_def_cfa_offset 192
	stp	x29, x30, [sp, 176]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 176
	str	w0, [sp, 12]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 168]
	mov	x1, 0
#APP
// 130 "attacker.c" 1
	.rept 10
	nop
	.endr
	
// 0 "" 2
#NO_APP
	add	x0, sp, 32
	mov	x2, 136
	mov	w1, 0
	bl	memset
	mov	w0, 7
	str	w0, [sp, 32]
	mov	w0, 136
	str	w0, [sp, 36]
	mov	x0, 16
	str	x0, [sp, 40]
	ldr	x0, [sp, 72]
	orr	x0, x0, 1
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	orr	x0, x0, 32
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	orr	x0, x0, 64
	str	x0, [sp, 72]
	add	x0, sp, 32
	mov	x4, 0
	mov	w3, -1
	mov	w2, -1
	mov	w1, 0
	bl	perf_event_open
	str	w0, [sp, 20]
	ldr	w0, [sp, 20]
	cmn	w0, #1
	bne	.L15
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	perror
	mov	x0, 0
	b	.L19
.L15:
	mov	w2, 0
	mov	x1, 9219
	ldr	w0, [sp, 20]
	bl	ioctl
	mov	w2, 0
	mov	x1, 9216
	ldr	w0, [sp, 20]
	bl	ioctl
#APP
// 163 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 166 "attacker.c" 1
	.global branch2_eq_label  
	.global branch2_else      
	cmp    w0, #0      
	branch2_eq_label:         
	b.eq   branch2_else       
	branch2_if:               
	.rept 1                
	nop                       
	.endr                     
	b     branch2_end         
	branch2_else:             
	.rept 1                
	nop                       
	.endr                     
	nop                       
	branch2_end:              
	
// 0 "" 2
// 189 "attacker.c" 1
	dsb sy
// 0 "" 2
// 190 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	mov	w2, 0
	mov	x1, 9217
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L17
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	perror
.L17:
	str	xzr, [sp, 24]
	add	x0, sp, 24
	mov	x2, 8
	mov	x1, x0
	ldr	w0, [sp, 20]
	bl	read
	cmp	x0, 8
	beq	.L18
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	perror
	str	xzr, [sp, 24]
.L18:
	ldr	w0, [sp, 20]
	bl	close
	ldr	x0, [sp, 24]
.L19:
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 168]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L20
	bl	__stack_chk_fail
.L20:
	mov	x0, x1
	ldp	x29, x30, [sp, 176]
	add	sp, sp, 192
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE38:
	.size	inner, .-inner
	.section	.rodata
	.align	3
.LC5:
	.string	"[ATK] address of outer branch: %p\n"
	.align	3
.LC6:
	.string	"[ATK] address of inner branch: %p\n"
	.align	3
.LC7:
	.string	"malloc failed"
	.align	3
.LC8:
	.string	"w"
	.align	3
.LC9:
	.string	"p2.txt"
	.align	3
.LC10:
	.string	"Loop ended at counter = %lu\n"
	.align	3
.LC11:
	.string	"%lu, %lu\n"
	.align	3
.LC12:
	.string	"Attacker(Parent) End"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB39:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x29, x30, [sp, 128]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 128
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 120]
	mov	x1, 0
#APP
// 207 "attacker.c" 1
	ldr    x1, =branch1_eq_label
	ldr    x0, =branch2_eq_label
	
// 0 "" 2
#NO_APP
	str	x1, [sp, 16]
	str	x0, [sp, 24]
	ldr	x0, [sp, 16]
	mov	x1, x0
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	printf
	ldr	x0, [sp, 24]
	mov	x1, x0
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	printf
	adrp	x0, :got:stdout
	ldr	x0, [x0, :got_lo12:stdout]
	ldr	x0, [x0]
	bl	fflush
	mov	x0, 26624
	movk	x0, 0x989, lsl 16
	bl	malloc
	str	x0, [sp, 32]
	ldr	x0, [sp, 32]
	cmp	x0, 0
	bne	.L22
	adrp	x0, .LC7
	add	x0, x0, :lo12:.LC7
	bl	perror
	mov	w0, 0
	b	.L30
.L22:
	str	wzr, [sp]
	adrp	x0, .LC8
	add	x1, x0, :lo12:.LC8
	adrp	x0, .LC9
	add	x0, x0, :lo12:.LC9
	bl	fopen
	str	x0, [sp, 40]
	str	xzr, [sp, 8]
	mov	x0, 34464
	movk	x0, 0x1, lsl 16
	str	x0, [sp, 48]
.L27:
	mov	x0, 34464
	movk	x0, 0x1, lsl 16
	bl	delay
	mov	w0, 0
	bl	inner
	str	x0, [sp, 56]
#APP
// 240 "attacker.c" 1
	dsb sy
// 0 "" 2
// 241 "attacker.c" 1
	isb
// 0 "" 2
// 242 "attacker.c" 1
	mrs x0, cntvct_el0
// 0 "" 2
#NO_APP
	str	x0, [sp, 64]
#APP
// 243 "attacker.c" 1
	isb
// 0 "" 2
#NO_APP
	ldrsw	x0, [sp]
	lsl	x0, x0, 5
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	ldr	x1, [sp, 64]
	str	x1, [x0]
	ldrsw	x0, [sp]
	lsl	x0, x0, 5
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	ldr	x1, [sp, 56]
	str	x1, [x0, 8]
	ldr	w0, [sp]
	add	w0, w0, 1
	str	w0, [sp]
	ldr	x1, [sp, 8]
	ldr	x0, [sp, 48]
	sub	x0, x1, x0
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	lsr	x0, x0, 63
	str	x0, [sp, 80]
	adrp	x0, .L24
	add	x0, x0, :lo12:.L24
	str	x0, [sp, 104]
	adrp	x0, .L25
	add	x0, x0, :lo12:.L25
	str	x0, [sp, 112]
	ldr	x0, [sp, 80]
	lsl	x0, x0, 3
	add	x1, sp, 104
	ldr	x0, [x1, x0]
	nop
	br	x0
.L25:
	ldr	x0, [sp, 8]
	add	x0, x0, 1
	str	x0, [sp, 8]
	b	.L27
.L24:
	ldr	x1, [sp, 8]
	adrp	x0, .LC10
	add	x0, x0, :lo12:.LC10
	bl	printf
	str	wzr, [sp, 4]
	b	.L28
.L29:
	ldrsw	x0, [sp, 4]
	lsl	x0, x0, 5
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	ldr	x2, [x0]
	ldrsw	x0, [sp, 4]
	lsl	x0, x0, 5
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	ldr	x0, [x0, 8]
	mov	x3, x0
	adrp	x0, .LC11
	add	x1, x0, :lo12:.LC11
	ldr	x0, [sp, 40]
	bl	fprintf
	ldr	w0, [sp, 4]
	add	w0, w0, 1
	str	w0, [sp, 4]
.L28:
	ldr	w1, [sp, 4]
	ldr	w0, [sp]
	cmp	w1, w0
	blt	.L29
	ldr	x0, [sp, 40]
	bl	fclose
	ldr	x0, [sp, 32]
	bl	free
	adrp	x0, .LC12
	add	x0, x0, :lo12:.LC12
	bl	puts
	mov	w0, 0
.L30:
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 120]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L31
	bl	__stack_chk_fail
.L31:
	mov	w0, w1
	ldp	x29, x30, [sp, 128]
	add	sp, sp, 144
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE39:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
