/ Speed test routine
/
/ Author: David Harper at obliquity.com
/
/ C prototype:
/
/ int vectorOps(void *a, void *b, void *c, int nsize,
/		int niters, int mode)
/
/ FLOATING POINT
/ mode =  0 --> NOP
/	  1 --> ADD
/	  2 --> MULTIPLY
/	  3 --> DIVIDE
/	  4 --> COSINE
/	  5 --> SQRT
/	  6 --> ATAN2
/	  7 --> Y LOG2(X)
/	  8 --> SINCOS
/	  9 --> 2^X - 1
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

/ Register usage
/ --------------
/
/ Input parameters:
/
/ RDI  *a
/ RSI  *b
/ RDX  *c
/ ECX  nsize
/ R8D  niters
/ R9D  mode
/
/ Globals:
/
/ R9   *a
/ R10  *b
/ R11  *c
/ R12  saved value of nsize
/
/ Within inner loop:
/
/ ECX  loop counter
/ RSI  index variable

define(`SRCA',	``('%r9,%rsi,8`)'')
define(`SRCB',	``('%r10,%rsi,8`)'')
define(`DEST',	``('%r11,%rsi,8`)'')
	
define(`CASE', `
        cmp     $$1,%r9d
        je      .L$2')

/----- Floating-point loop prolog and epilog -----

define(`FP_PROLOG',`
	.align	4
.L$1:
	push	%rbx
	push	%r12

	movq	%rdi,%r9
	movq	%rsi,%r10
	movq	%rdx,%r11

	movl	%ecx,%r12d

.L$1OuterLoop:
	movl	%r12d,%ecx

	xorq	%rsi,%rsi
.L$1InnerLoop:')

define(`FP_EPILOG',`
	incq	%rsi

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	movl	%r12d,%eax
	cltq

	pop	%r12
	pop	%rbx

	ret')

/----- Integer loop prolog and epilog -----

define(`INT_PROLOG',`
	.align	4
.L$1:
	push	%rbx
	push	%r12

	movq	%rdi,%r9
	movq	%rsi,%r10
	movq	%rdx,%r11

	movl	%ecx,%r12d

.L$1OuterLoop:
	movl	%r12d,%ecx

	xorq	%rsi,%rsi
	xorq	%rax,%rax
.L$1InnerLoop:')

define(`INT_EPILOG',`
	incq	%rsi

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	movl	%r12d,%eax
	cltq

	pop	%r12
	pop	%rbx

	ret')


/----- The code begins here -----

	.text

	.align	4
.globl	vectorOps
	.type	vectorOps,@function
vectorOps:

/	Test niters > 0
	testl	%ecx,%ecx
	jg	.L1

	xor	%eax,%eax

	ret
.L1:

/	Test nsize > 0
	testl	%r8d,%r8d
	jg	.L2

	xor	%eax,%eax

	ret
.L2:
/	On the value of mode, skip to the relevant section
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
	CASE(17, imultiply)
	CASE(18, idivide)

/	mode lies outside the range, so exit
	ret

/----- Floating-point tests -----

	FP_PROLOG(nop)
	FP_EPILOG(nop)

	FP_PROLOG(add)
	fldl	SRCA
	faddl	SRCB
	fstpl	DEST
	FP_EPILOG(add)

	FP_PROLOG(multiply)
	fldl	SRCA
	fmull	SRCB
	fstpl	DEST
	FP_EPILOG(multiply)

	FP_PROLOG(divide)
	fldl	SRCA
	fdivrl	SRCB
	fstpl	DEST
	FP_EPILOG(divide)

	FP_PROLOG(cosine)
	fldl	SRCA
	fcos
	fstpl	DEST
	FP_EPILOG(cosine)

	FP_PROLOG(sqrt)
	fldl	SRCA
	fsqrt
	fstpl	DEST
	FP_EPILOG(sqrt)

	FP_PROLOG(atan)
	fldl	SRCA
	fldl	SRCB
	fpatan
	fstpl	DEST
	FP_EPILOG(atan)

	FP_PROLOG(ylogx)
	fldl	SRCA
	fldl	SRCB
	fyl2x
	fstpl	DEST
	FP_EPILOG(ylogx)

	FP_PROLOG(sincos)
	fldl	SRCA
	fsincos
	fstpl	DEST
	fstpl	DEST
	FP_EPILOG(sincos)

	FP_PROLOG(exp)
	fldl	SRCA
	f2xm1
	fstpl	DEST
	FP_EPILOG(exp)

/----- Integer tests -----

	INT_PROLOG(inop)
	nop
	INT_EPILOG(inop)

	INT_PROLOG(ifetch)
	movq	SRCA,%rax
	INT_EPILOG(ifetch)

	INT_PROLOG(irandomfetch)
	movq	SRCA,%rsi
	INT_EPILOG(irandomfetch)

	INT_PROLOG(istore)
	movq	%rsi,DEST
	INT_EPILOG(istore)

	INT_PROLOG(ifetchandstore)
	movq	SRCA,%rax
	movq	%rax,DEST
	INT_EPILOG(ifetchandstore)

	INT_PROLOG(iadd)
	movq	SRCA,%rax
	addq	SRCB,%rax
	movq	%rax,DEST
	INT_EPILOG(iadd)

	INT_PROLOG(isum)
	addq	SRCA,%rax
	INT_EPILOG(isum)

	INT_PROLOG(imultiply)
	movq	SRCA,%rax
	mulq	SRCB
	INT_EPILOG(imultiply)

	INT_PROLOG(idivide)
	xorq	%rdx,%rdx
	movq	SRCA,%rax
	divq	SRCB
	INT_EPILOG(idivide)

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.ident	"David Harper at www.obliquity.com"
