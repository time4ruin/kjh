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
// 39 "branches.c" 1
	.rept 185
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
// 49 "branches.c" 1
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
// 82 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 85 "branches.c" 1
	.global branch1_eq_label  
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
// 108 "branches.c" 1
	dsb sy
// 0 "" 2
// 109 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	mov	w2, 0
	mov	x1, 9217
	ldr	w0, [sp, 20]
	bl	ioctl
#APP
// 114 "branches.c" 1
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
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 154 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 155 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 156 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 157 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 158 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 159 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 160 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 161 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 162 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 163 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 164 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 165 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 166 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 167 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 168 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 169 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 170 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 171 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 172 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 173 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 174 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 175 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 176 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 177 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 178 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 179 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 180 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 181 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 182 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 183 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 184 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 185 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 186 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 187 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 188 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 189 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 190 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 191 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 192 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 193 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 194 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 195 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 196 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 197 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 198 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 199 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 200 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 201 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 202 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 203 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 204 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 205 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 206 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 207 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 208 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 209 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 210 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 211 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 212 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 213 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 214 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 215 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 216 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 217 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 218 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 219 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 220 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 221 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 222 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 223 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 224 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 225 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 226 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 227 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 228 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 229 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 230 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 231 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 232 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 233 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 234 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 235 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 236 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 237 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 238 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 239 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 240 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 241 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 242 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 243 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 244 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 245 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 246 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 247 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 248 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 249 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 250 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 251 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 252 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 253 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 254 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 255 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 256 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 257 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 258 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 259 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 260 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 261 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 262 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 263 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 264 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 265 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 266 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 267 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 268 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 269 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 270 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 271 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 272 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 273 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 274 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 275 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 276 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 277 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 278 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 279 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 280 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 281 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 282 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 283 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 284 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 285 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 286 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 287 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 288 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 289 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 290 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 291 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 292 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 293 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 294 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 295 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 296 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 297 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 298 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 299 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 300 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 301 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 302 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 303 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 304 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 305 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 306 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 307 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 308 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 309 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 310 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 311 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 312 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 313 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 314 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 315 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 316 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 317 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 318 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 319 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 320 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 321 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 322 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 323 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 324 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 325 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 326 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 327 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 328 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 329 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 330 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 331 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 332 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 333 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 334 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 335 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 336 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 337 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 338 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 339 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 340 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 341 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 342 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 343 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 344 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 345 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 346 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 347 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 348 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 349 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 350 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 351 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 352 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 353 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 354 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 355 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 356 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 357 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 358 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 359 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 360 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 361 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 362 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 363 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 364 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 365 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 366 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 367 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 368 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 369 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 370 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 371 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 372 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 373 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 374 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 375 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 376 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 377 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 378 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 379 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 380 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 381 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 382 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 383 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 384 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 385 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 386 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 387 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 388 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 389 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 390 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 391 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 392 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 393 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 394 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 395 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 396 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 397 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 398 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 399 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 400 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 401 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 402 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 403 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 404 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 405 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 406 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 407 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 408 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 409 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 410 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 411 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 412 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 413 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 414 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 415 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 416 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 417 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 418 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 419 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 420 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 421 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 422 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 423 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 424 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 425 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 426 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 427 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 428 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 429 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 430 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 431 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 432 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 433 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 434 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 435 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 436 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 437 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 438 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 439 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 440 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 441 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 442 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 443 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 444 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 445 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 446 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 447 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 448 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 449 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 450 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 451 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 452 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 453 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 454 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 455 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 456 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 457 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 458 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 459 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 460 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 461 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 462 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 463 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 464 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 465 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 466 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 467 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 468 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 469 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 470 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 471 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 472 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 473 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 474 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 475 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 476 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 477 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 478 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 479 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 480 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 481 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 482 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 483 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 484 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 485 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 486 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 487 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 488 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 489 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 490 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 491 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 492 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 493 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 494 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 495 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 496 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 497 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 498 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 499 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 500 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 501 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 502 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 503 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 504 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 505 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 506 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 507 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 508 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 509 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 510 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 511 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 512 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 513 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 514 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 515 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 516 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 517 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 518 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 519 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 520 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 521 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 522 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 523 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 524 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 525 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 526 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 527 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 528 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 529 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 530 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 531 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 532 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 533 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 534 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 535 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 536 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 537 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 538 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 539 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 540 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 541 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 542 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 543 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 544 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 545 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 546 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 547 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 548 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 549 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 550 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 551 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 552 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 553 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 554 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 555 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 556 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 557 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 558 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 559 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 560 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 561 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 562 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 563 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 564 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 565 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 566 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 567 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 568 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 569 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 570 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 571 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 572 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 573 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 574 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 575 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 576 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 577 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 578 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 579 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 580 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 581 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 582 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 583 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 584 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 585 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 586 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 587 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 588 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 589 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 590 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 591 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 592 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 593 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 594 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 595 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 596 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 597 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 598 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 599 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 600 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 601 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 602 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 603 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 604 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 605 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 606 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 607 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 608 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 609 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 610 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 611 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 612 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 613 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 614 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 615 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 616 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 617 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 618 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 619 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 620 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 621 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 622 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 623 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 624 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 625 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 626 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 627 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 628 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 629 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 630 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 631 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 632 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 633 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 634 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 635 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 636 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 637 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 638 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 639 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 640 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 641 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 642 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 643 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 644 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 645 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 646 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 647 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 648 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 649 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 650 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 651 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 652 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 653 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 654 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 655 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 656 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 657 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 658 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 659 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 660 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 661 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 662 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 663 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 664 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 665 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 666 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 667 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 668 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 669 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 670 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 671 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 672 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 673 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 674 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 675 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 676 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 677 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 678 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 679 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 680 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 681 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 682 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 683 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 684 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 685 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 686 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 687 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 688 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 689 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 690 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 691 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 692 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 693 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 694 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 695 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 696 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 697 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 698 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 699 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 700 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 701 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 702 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 703 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 704 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 705 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 706 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 707 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 708 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 709 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 710 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 711 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 712 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 713 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 714 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 715 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 716 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 717 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 718 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 719 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 720 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 721 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 722 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 723 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 724 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 725 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 726 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 727 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 728 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 729 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 730 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 731 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 732 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 733 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 734 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 735 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 736 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 737 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 738 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 739 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 740 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 741 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 742 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 743 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 744 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 745 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 746 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 747 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 748 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 749 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 750 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 751 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 752 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 753 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 754 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 755 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 756 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 757 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 758 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 759 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 760 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 761 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 762 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 763 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 764 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 765 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 766 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 767 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 768 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 769 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 770 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 771 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 772 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 773 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 774 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 775 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 776 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 777 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 778 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 779 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 780 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 781 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 782 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 783 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 784 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 785 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 786 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 787 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 788 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 789 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 790 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 791 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 792 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 793 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 794 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 795 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 796 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 797 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 798 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 799 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 800 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 801 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 802 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 803 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 804 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 805 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 806 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 807 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 808 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 809 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 810 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 811 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 812 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 813 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 814 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 815 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 816 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 817 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 818 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 819 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 820 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 821 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 822 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 823 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 824 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 825 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 826 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 827 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 828 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 829 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 830 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 831 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 832 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 833 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 834 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 835 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 836 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 837 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 838 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 839 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 840 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 841 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 842 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 843 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 844 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 845 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 846 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 847 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 848 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 849 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 850 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 851 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 852 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 853 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 854 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 855 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 856 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 857 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 858 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 859 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 860 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 861 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 862 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 863 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 864 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 865 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 866 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 867 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 868 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 869 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 870 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 871 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 872 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 873 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 874 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 875 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 876 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 877 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 878 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 879 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 880 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 881 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 882 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 883 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 884 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 885 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 886 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 887 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 888 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 889 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 890 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 891 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 892 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 893 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 894 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 895 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 896 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 897 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 898 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 899 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 900 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 901 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 902 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 903 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 904 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 905 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 906 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 907 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 908 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 909 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 910 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 911 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 912 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 913 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 914 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 915 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 916 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 917 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 918 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 919 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 920 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 921 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 922 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 923 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 924 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 925 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 926 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 927 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 928 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 929 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 930 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 931 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 932 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 933 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 934 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 935 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 936 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 937 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 938 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 939 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 940 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 941 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 942 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 943 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 944 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 945 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 946 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 947 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 948 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 949 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 950 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 951 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 952 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 953 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 954 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 955 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 956 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 957 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 958 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 959 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 960 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 961 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 962 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 963 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 964 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 965 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 966 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 967 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 968 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 969 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 970 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 971 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 972 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 973 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 974 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 975 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 976 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 977 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 978 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 979 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 980 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 981 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 982 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 983 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 984 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 985 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 986 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 987 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 988 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 989 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 990 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 991 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 992 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 993 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 994 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 995 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 996 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 997 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 998 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 999 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1000 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1001 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1002 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1003 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1004 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1005 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1006 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1007 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1008 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1009 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1010 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1011 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1012 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1013 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1014 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1015 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1016 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1017 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1018 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1019 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1020 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1021 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1022 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1023 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1024 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1025 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1026 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1027 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1028 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1029 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1030 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1031 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1032 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1033 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1034 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1035 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1036 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1037 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1038 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1039 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1040 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1041 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1042 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1043 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1044 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1045 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1046 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1047 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1048 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1049 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1050 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1051 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1052 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1053 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1054 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1055 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1056 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1057 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1058 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1059 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1060 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1061 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1062 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1063 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1064 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1065 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1066 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1067 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1068 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1069 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1070 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1071 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1072 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1073 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1074 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1075 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1076 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1077 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1078 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1079 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1080 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1081 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1082 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1083 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1084 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1085 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1086 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1087 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1088 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1089 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1090 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1091 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1092 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1093 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1094 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1095 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1096 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1097 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1098 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1099 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1100 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1101 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1102 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1103 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1104 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1105 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1106 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1107 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1108 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1109 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1110 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1111 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1112 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1113 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1114 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1115 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1116 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1117 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1118 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1119 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1120 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1121 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1122 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1123 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1124 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1125 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1126 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1127 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1128 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1129 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1130 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1131 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1132 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1133 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1134 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1135 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1136 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1137 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1138 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1139 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1140 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1141 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1142 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1143 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1144 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1145 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1146 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1147 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1148 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1149 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1150 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1151 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1152 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1153 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1154 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1155 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1156 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1157 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1158 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1159 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1160 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1161 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1162 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1163 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1164 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1165 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1166 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1167 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1168 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1169 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1170 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1171 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1172 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1173 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1174 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1175 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1176 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1177 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1178 "branches.c" 1
	.rept 8000
	nop
	.endr
	
// 0 "" 2
// 1179 "branches.c" 1
	.rept 4684
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
#APP
// 1189 "branches.c" 1
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
// 1222 "branches.c" 1
	dsb sy
// 0 "" 2
// 1223 "branches.c" 1
	isb
// 0 "" 2
#NO_APP
	ldr	w0, [sp, 12]
#APP
// 1224 "branches.c" 1
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
// 1239 "branches.c" 1
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
