		.data
		.balign 4
negSign:	.asciiz "-"
		
		.balign 4
dot:	.asciiz "."
		.balign 4
percentD:	.asciiz "%d"

		.balign 4
return		.word 0

testValue:
        .float 0.5
        .float 0.25
        .float -1.0
        .float 100.0
        .float 1234.567
        .float -9876.543
        .float 7070.7070
        .float 3.3333
        .float 694.3e-9
        .float 6.0221e2
        .float 6.0221e23
        .word 0 @ end of list
.global main
.global printf

main:
	LDR r1,=return
	STR lr,[r1]	@save return address
	MOV r2, #0	@testValue pointer

_start:
	LDR     r3,=testValue
        LDR     r4,[r3,r2]	@ r4=testValue[r2]
	CMP     r4, #0		@ check end
	BEQ	_end
	@check sign
	AND	r5,r4,#0x80000000
	CMP	r5,#0x80000000
	BLEQ:	_printNeg
	@exponent
	MOV	r5,r0, LSL #1 @rmv sign
	MOV	r5,r5, LSR #24	@rmv frac
	SUB	r5,r5, #127	@get expo
	MOV	r6,r4, LSL #8
	ORR	r6,r6,#0x80000000
	MOV 	r7,#31
	SUB	r7,r7,r5
	CMP	r7,#0
	BGE	MOV r6,r6, LSR r7
	BLLT	_negExpo
	BL	_printInt @int
	@fraction
	MOV	r8,r4, LSL #9
	MOV	r8,r8, LSL r5
	BL	_printFraction
	ADD	r2,r2,#4
	B	_start
_printFraction:
	SUB 	sp,sp,#4
	STR	lr,[sp,#0]
	STR	r1,[sp,#4]
	LDR	r0,=dot
	BL	printf
	MOV	r1,r8
	LDR	r0,=percentD
	BL	printf
	LDR	lr,[sp,#0]
	ADD	sp,sp,#4
	MOV	pc,lr
_negExpo:
	SUB 	sp,sp,#4
	STR	lr,[sp,#0]
	CMP     r7, #-1
	LDRGT	lr,[sp,#0]
	ADDGT	sp,sp,#4
	MOVGT	pc,lr	
	MOV     r6, r6, LSL #1	
        ADD     r7, r7, #1
        BLLT     _negExpo
	LDR	lr,[sp,#0]
	ADD	sp,sp,#4
	MOV	pc,lr
_printNeg:
	SUB	sp,sp,#4
	STR 	lr,[sp,#0]
	LDR 	r0,=negSign
	BL 	printf
	LDR	lr, [sp,#0]
	ADD 	sp,sp,#4
	MOV 	pc, lr
_printInt:
	SUB 	sp,sp,#8
	STR 	lr,[sp,#0]
	STR	r1,[sp,#4]
	LDR	r0,=percentD
	MOV	r1,r6
	BL	printf
	LDR	r1,[sp,#4]
	LDR	lr, [sp,#0]
	ADD 	sp,sp,#8
	MOV 	pc, lr
_end:
        MOV     r7, #1
        SWI     0
