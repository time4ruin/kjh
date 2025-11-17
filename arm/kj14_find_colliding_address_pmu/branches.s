	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.type	perf_event_open, %function
perf_event_open:
.LFB28:
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
.LFE28:
	.size	perf_event_open, .-perf_event_open
	.align	2
	.global	dummy1
	.type	dummy1, %function
dummy1:
.LFB29:
	.cfi_startproc
#APP
// 35 "branches.c" 1
	.rept 145
	nop
	.endr
	
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE29:
	.size	dummy1, .-dummy1
	.section	.rodata
	.align	3
.LC0:
	.string	"perf_event_open"
	.align	3
.LC1:
	.string	"read"
	.text
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB30:
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
// 43 "branches.c" 1
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
	b	.L8
.L5:
	mov	w2, 0
	mov	x1, 9219
	ldr	w0, [sp, 20]
	bl	ioctl
	mov	w2, 0
	mov	x1, 9216
	ldr	w0, [sp, 20]
	bl	ioctl
#APP
// 76 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 79 "branches.c" 1
	.global branch1_eq_label  
	.global branch1_else      
	cmp    w0, #0      
	branch1_eq_label:         
	b.eq   branch1_else       
	branch1_if:               
	nop                       
	b     branch1_end         
	branch1_else:             
	nop                       
	branch1_end:              
	
// 0 "" 2
// 103 "branches.c" 1
	dsb sy
// 0 "" 2
// 104 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	mov	w2, 0
	mov	x1, 9217
	ldr	w0, [sp, 20]
	bl	ioctl
#APP
// 109 "branches.c" 1
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
	beq	.L7
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	perror
	str	xzr, [sp, 24]
.L7:
	ldr	w0, [sp, 20]
	bl	close
	ldr	x0, [sp, 24]
.L8:
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 168]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L9
	bl	__stack_chk_fail
.L9:
	mov	x0, x1
	ldp	x29, x30, [sp, 176]
	add	sp, sp, 192
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE30:
	.size	branch1, .-branch1
	.align	2
	.global	dummy2
	.type	dummy2, %function
dummy2:
.LFB31:
	.cfi_startproc
#APP
// 125 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 126 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 127 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 128 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 129 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 130 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 131 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 132 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 133 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 134 "branches.c" 1
	.rept 3103
	nop
	.endr
	
// 0 "" 2
#NO_APP
	nop
	ret
	.cfi_endproc
.LFE31:
	.size	dummy2, .-dummy2
	.section	.rodata
	.align	3
.LC2:
	.string	"ioctl RESET"
	.align	3
.LC3:
	.string	"ioctl ENABLE"
	.align	3
.LC4:
	.string	"ioctl DISABLE"
	.text
	.align	2
	.global	branch2
	.type	branch2, %function
branch2:
.LFB32:
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
	bne	.L12
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	perror
	mov	x0, 0
	b	.L18
.L12:
	mov	w2, 0
	mov	x1, 9219
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L14
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	perror
.L14:
	mov	w2, 0
	mov	x1, 9216
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L15
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	perror
.L15:
#APP
// 172 "branches.c" 1
	dsb sy
// 0 "" 2
// 173 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 174 "branches.c" 1
	.global branch2_eq_label  
	cmp    w0, #0      
	branch2_eq_label:         
	b.eq   branch2_else       
	branch2_if:               
	nop                       
	b     branch2_end         
	branch2_else:             
	nop                       
	branch2_end:              
	
// 0 "" 2
// 189 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	mov	w2, 0
	mov	x1, 9217
	ldr	w0, [sp, 20]
	bl	ioctl
	cmn	w0, #1
	bne	.L16
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	perror
.L16:
	str	xzr, [sp, 24]
	add	x0, sp, 24
	mov	x2, 8
	mov	x1, x0
	ldr	w0, [sp, 20]
	bl	read
	cmp	x0, 8
	beq	.L17
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	perror
	str	xzr, [sp, 24]
.L17:
	ldr	w0, [sp, 20]
	bl	close
	ldr	x0, [sp, 24]
.L18:
	mov	x1, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 168]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L19
	bl	__stack_chk_fail
.L19:
	mov	x0, x1
	ldp	x29, x30, [sp, 176]
	add	sp, sp, 192
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE32:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
