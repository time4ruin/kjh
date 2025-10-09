	.arch armv8-a
	.file	"branches.c"
	.text
	.align	2
	.global	branch1
	.type	branch1, %function
branch1:
.LFB0:
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
// 10 "branches.c" 1
	dsb sy
// 0 "" 2
// 11 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 24
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 13 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 15 "branches.c" 1
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
// 35 "branches.c" 1
	dsb sy
// 0 "" 2
// 36 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 38 "branches.c" 1
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
	beq	.L3
	bl	__stack_chk_fail
.L3:
	mov	x0, x1
	ldp	x29, x30, [sp, 64]
	add	sp, sp, 80
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	branch1, .-branch1
	.align	2
	.global	branch2
	.type	branch2, %function
branch2:
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
// 46 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 47 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 48 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 49 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 50 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 51 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 52 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 53 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 54 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 55 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 56 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 57 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 58 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 59 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 60 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 61 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 62 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 63 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 64 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 65 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 66 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 67 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 68 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 69 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 70 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 71 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 72 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 73 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 74 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 75 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 76 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 77 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 78 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 79 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 80 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 81 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 82 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 83 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 84 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 85 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 86 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 87 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 88 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 89 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 90 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 91 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 92 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 93 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 94 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 95 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 96 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 97 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 98 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 99 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 100 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 101 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 102 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 103 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 104 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 105 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 106 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 107 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 108 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 109 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 110 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 111 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 112 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 113 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 114 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 115 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 116 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 117 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 118 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 119 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 120 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 121 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 122 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 123 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 124 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
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
	.rept 8000
nop
.endr

// 0 "" 2
// 135 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 136 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 137 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 138 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 139 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 140 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 141 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 142 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 143 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 144 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 145 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 146 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 147 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 148 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 149 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 150 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 151 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 152 "branches.c" 1
	.rept 8000
nop
.endr

// 0 "" 2
// 153 "branches.c" 1
	.rept 1575
nop
.endr

// 0 "" 2
// 156 "branches.c" 1
	dsb sy
// 0 "" 2
// 157 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 24
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 159 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 161 "branches.c" 1
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
// 181 "branches.c" 1
	dsb sy
// 0 "" 2
// 182 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	add	x0, sp, 40
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
#APP
// 184 "branches.c" 1
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
	beq	.L6
	bl	__stack_chk_fail
.L6:
	mov	x0, x1
	ldp	x29, x30, [sp, 64]
	add	sp, sp, 80
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	branch2, .-branch2
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
