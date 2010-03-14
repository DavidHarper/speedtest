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
/	 11 --> FETCH
/	 12 --> FETCH AND STORE
/	 13 --> ADD
/	 14 --> MULTIPLY
/	 15 --> DIVIDE

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
/ RAX  *a
/ RBX  *b
/ RDX  *c
/ EDI  saved value of nsize
/ R9   saved rbx
/
/ Within inner loop:
/
/ ECX  loop counter
/ RSI  index variable

define(`LOC',  ``('$1,%rsi,8`)'')
	
define(`CASE', `
        cmp     $$1,%r9d
        je      .L$2')

/----- Floating-point loop prolog and epilog -----

define(`FP_PROLOG',`
	.align	4
.L$1:
	movq	%rbx,%r9

	movq	%rdi,%rax
	movq	%rsi,%rbx
	movq	%rdx,%rdx

	movl	%ecx,%edi

.L$1OuterLoop:
	movl	%edi,%ecx

	xorq	%rsi,%rsi
.L$1InnerLoop:')

define(`FP_EPILOG',`
	incq	%rsi

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	movq	%r9,%rbx

	movq	$`'1,%rax

	ret')

/----- Integer loop prolog and epilog -----

define(`INT_PROLOG',`
	.align	4
.L$1:
	movq	%rbx,%r9

	movq	%rdi,%rax
	movq	%rsi,%rbx
	movq	%rdx,%rdx

	movl	%ecx,%edi

.L$1OuterLoop:
	movl	%edi,%ecx

	xorq	%rsi,%rsi
.L$1InnerLoop:')

define(`INT_EPILOG',`
	incq	%rsi

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	movq	%r9,%rbx

	movq	$`'1,%rax

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
	CASE(12, istore)
	CASE(13, ifetchandstore)
	CASE(14, iadd)
	CASE(15, imultiply)
	CASE(16, idivide)

/	mode lies outside the range, so exit
	ret

/----- Floating-point tests -----

	FP_PROLOG(nop)
	FP_EPILOG(nop)

	FP_PROLOG(add)
	fldl	LOC(%rax)
	faddl	LOC(%rbx)
	fstpl	LOC(%rdx)
	FP_EPILOG(add)

	FP_PROLOG(multiply)
	fldl	LOC(%rax)
	fmull	LOC(%rbx)
	fstpl	LOC(%rdx)
	FP_EPILOG(multiply)

	FP_PROLOG(divide)
	fldl	LOC(%rax)
	fdivrl	LOC(%rbx)
	fstpl	LOC(%rdx)
	FP_EPILOG(divide)

	FP_PROLOG(cosine)
	fldl	LOC(%rax)
	fcos
	fstpl	LOC(%rdx)
	FP_EPILOG(cosine)

	FP_PROLOG(sqrt)
	fldl	LOC(%rax)
	fsqrt
	fstpl	LOC(%rdx)
	FP_EPILOG(sqrt)

	FP_PROLOG(atan)
	fldl	LOC(%rax)
	fldl	LOC(%rbx)
	fpatan
	fstpl	LOC(%rdx)
	FP_EPILOG(atan)

	FP_PROLOG(ylogx)
	fldl	LOC(%rax)
	fldl	LOC(%rbx)
	fyl2x
	fstpl	LOC(%rdx)
	FP_EPILOG(ylogx)

	FP_PROLOG(sincos)
	fldl	LOC(%rax)
	fsincos
	fstpl	LOC(%rdx)
	fstpl	LOC(%rdx)
	FP_EPILOG(sincos)

	FP_PROLOG(exp)
	fldl	LOC(%rax)
	f2xm1
	fstpl	LOC(%rdx)
	FP_EPILOG(exp)

/----- Integer tests -----

	INT_PROLOG(inop)
	nop
	INT_EPILOG(inop)

	INT_PROLOG(ifetch)
	movq	LOC(%rax),%r10
	INT_EPILOG(ifetch)

	INT_PROLOG(istore)
	movq	%rsi,LOC(%rdx)
	INT_EPILOG(istore)

	INT_PROLOG(ifetchandstore)
	movq	LOC(%rax),%r10
	movq	%r10,LOC(%rdx)
	INT_EPILOG(ifetchandstore)

	INT_PROLOG(iadd)
	movq	LOC(%rax),%r10
	addq	LOC(%rbx),%r10
	movq	%r10,LOC(%rdx)
	INT_EPILOG(iadd)

	INT_PROLOG(imultiply)
	INT_EPILOG(imultiply)

	INT_PROLOG(idivide)
	INT_EPILOG(idivide)

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.ident	"David Harper at www.obliquity.com"
