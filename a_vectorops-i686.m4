/ speedtest : a CPU speed test utility
/
/ Copyright (C) 2013 David Harper at obliquity.com
/
/ This program is free software: you can redistribute it and/or modify
/ it under the terms of the GNU General Public License as published by
/ the Free Software Foundation, either version 3 of the License, or
/ (at your option) any later version.
/
/ This program is distributed in the hope that it will be useful,
/ but WITHOUT ANY WARRANTY; without even the implied warranty of
/ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/ GNU General Public License for more details.
/
/ You should have received a copy of the GNU General Public License
/ along with this program.  If not, see [http://www.gnu.org/licenses/].

/ C prototype:
/
/ void vectorOps(void *a, void *b, void *c, int nsize,
/		 int niters, int mode)
/
/ mode = 0 --> NOP
/	 1 --> ADD
/	 2 --> MULTIPLY
/	 3 --> DIVIDE
/	 4 --> COSINE
/	 5 --> SQRT
/	 6 --> ATAN2
/	 7 --> Y LOG2(X)
/	 8 --> SINCOS
/        9 --> 2^X - 1
/
/ INTEGER
/ mode = 10 --> NOP
/	 11 --> SEQUENTIAL FETCH
/        12 --> RANDOM FETCH
/        13 --> STORE
/	 14 --> FETCH AND STORE
/	 15 --> ADD
/        16 --> SUM
/	 17 --> MULTIPLY
/	 18 --> DIVIDE

define(`SRCA',	`%eax')
define(`SRCB',	`%ebx')
define(`CTRA',	`%ecx')
define(`TEMP',	`%edx')
define(`CTRB',	`%esi')
define(`DEST',	`%edi')
	
define(`CASE', `
        cmpl    $$1,%eax
        je      .L$2')

define(`PROLOG',`
	.align	4
.L$1:
	movl	24(%ebp),CTRA

.L$1OuterLoop:
	movl	CTRA,CTRB

	movl	20(%ebp),CTRA
	movl	8(%ebp),SRCA
	movl	12(%ebp),SRCB
	movl	16(%ebp),DEST

.L$1InnerLoop:')

define(`FP_EPILOG',`
	addl	$`'8,SRCA
	addl	$`'8,SRCB
	addl	$`'8,DEST

	loop	.L$1InnerLoop

	movl	%esi,%ecx
	loop	.L$1OuterLoop

	movl	24(%ebp),%eax

	jmp	.Lexit')


define(`INT_EPILOG',`
	addl	$`'4,SRCA
	addl	$`'4,SRCB
	addl	$`'4,DEST

	loop	.L$1InnerLoop

	movl	%esi,%ecx
	loop	.L$1OuterLoop

	movl	24(%ebp),%eax

	jmp	.Lexit')

	.text

	.align	4
.globl	vectorOps
	.type	vectorOps,@function
vectorOps:
/	Set up the stack frame
	pushl	%ebp
	movl	%esp,%ebp

/	Save registers that we want to restore later
	pushl	%esi
	pushl	%edi
	pushl	%ebx

/	Test niters > 0
	movl	24(%ebp),%ecx
	xorl	%eax,%eax
	cmpl	%ecx,%eax
	jge	.Lexit

/	Test nsize > 0
	movl	20(%ebp),%ecx
	xorl	%eax,%eax
	cmpl	%ecx,%eax
	jge	.Lexit

/	On the value of mode, skip to the relevant section
	movl	28(%ebp),%eax

	CASE(0, nop)
	CASE(1, add)
	CASE(2, multiply)
	CASE(3, divide)
	CASE(4, cosine)
	CASE(5, sqrt)
	CASE(6, atan)
	CASE(7, ylogx)
	CASE(8, sincos)
	CASE(9, exp)

	CASE(10, inop)
	CASE(11, ifetch)
	CASE(12, irandomfetch)
	CASE(13, istore)
	CASE(14, ifetchandstore)
	CASE(15, iadd)
	CASE(16, isum)
/	CASE(17, imultiply)
/	CASE(18, idivide)

/	mode lies outside the range, so exit
	xorl	%eax,%eax
	jmp	.Lexit

/----- Floating-point tests -----

	PROLOG(nop)
	FP_EPILOG(nop)

	PROLOG(add)
	fldl	(SRCA)
	faddl	(SRCB)
	fstpl	(DEST)
	FP_EPILOG(add)

	PROLOG(multiply)
	fldl	(SRCA)
	fmull	(SRCB)
	fstpl	(DEST)
	FP_EPILOG(multiply)

	PROLOG(divide)
	fldl	(SRCA)
	fdivrl	(SRCB)
	fstpl	(DEST)
	FP_EPILOG(divide)

	PROLOG(cosine)
	fldl	(SRCA)
	fcos
	fstpl	(DEST)
	FP_EPILOG(cosine)

	PROLOG(sqrt)
	fldl	(SRCA)
	fsqrt
	fstpl	(DEST)
	FP_EPILOG(sqrt)

	PROLOG(atan)
	fldl	(SRCA)
	fldl	(SRCB)
	fpatan
	fstpl	(DEST)
	FP_EPILOG(atan)

	PROLOG(ylogx)
	fldl	(SRCA)
	fldl	(SRCB)
	fyl2x
	fstpl	(DEST)
	FP_EPILOG(ylogx)

	PROLOG(sincos)
	fldl	(SRCA)
	fsincos
	fstpl	(DEST)
	fstpl	(DEST)
	FP_EPILOG(sincos)

	PROLOG(exp)
	fldl	(SRCA)
	f2xm1
	fstpl	(DEST)
	FP_EPILOG(exp)

/----- Integer tests -----

	PROLOG(inop)
	INT_EPILOG(inop)

	PROLOG(ifetch)
	movl	(SRCA),TEMP
	INT_EPILOG(ifetch)

	PROLOG(irandomfetch)
	movl	(SRCA),TEMP
	INT_EPILOG(irandomfetch)

	PROLOG(istore)
	movl	TEMP,(DEST)
	INT_EPILOG(istore)

	PROLOG(ifetchandstore)
	movl	(SRCA),TEMP
	movl	TEMP,(DEST)
	INT_EPILOG(ifetchandstore)

	PROLOG(iadd)
	movl	(SRCA),TEMP
	addl	(SRCB),TEMP
	movl	TEMP,(DEST)
	INT_EPILOG(iadd)

	PROLOG(isum)
	addl	(SRCA),TEMP
	INT_EPILOG(isum)

/	Multiplication and division are not implemented
/	in the 32-bit version, as they require the EAX
/	and EDX registers.
/
/	PROLOG(imultiply)
/	movl	(SRCA),TEMP
/	mull	(SRCB)
/	INT_EPILOG(imultiply)

/	PROLOG(idivide)
/	xorl	TEMP,TEMP
/	movl	(SRCA),TEMP
/	divl	(SRCB)
/	INT_EPILOG(idivide)

.Lexit:
/	Restore the saved registers
	popl	%ebx
	popl	%edi
	popl	%esi
/	Clear up the stack frame and return
	leave
	ret

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.ident	"David Harper at www.obliquity.com"
