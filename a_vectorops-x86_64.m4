/ Speed test routine
/
/ Author: David Harper at obliquity.com
/
/ C prototype:
/
/ int vectorOps(double *a, double *b, double *c, int nsize,
/		int niters, int mode)
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

define(`PROLOG',`
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

define(`EPILOG',`
	incq	%rsi

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	movq	%r9,%rbx

	movq	$`'1,%rax

	ret')

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

/	mode lies outside the range, so exit
	ret

	PROLOG(nop)
	EPILOG(nop)

	PROLOG(add)
	fldl	LOC(%rax)
	faddl	LOC(%rbx)
	fstpl	LOC(%rdx)
	EPILOG(add)

	PROLOG(multiply)
	fldl	LOC(%rax)
	fmull	LOC(%rbx)
	fstpl	LOC(%rdx)
	EPILOG(multiply)

	PROLOG(divide)
	fldl	LOC(%rax)
	fdivrl	LOC(%rbx)
	fstpl	LOC(%rdx)
	EPILOG(divide)

	PROLOG(cosine)
	fldl	LOC(%rax)
	fcos
	fstpl	LOC(%rdx)
	EPILOG(cosine)

	PROLOG(sqrt)
	fldl	LOC(%rax)
	fsqrt
	fstpl	LOC(%rdx)
	EPILOG(sqrt)

	PROLOG(atan)
	fldl	LOC(%rax)
	fldl	LOC(%rbx)
	fpatan
	fstpl	LOC(%rdx)
	EPILOG(atan)

	PROLOG(ylogx)
	fldl	LOC(%rax)
	fldl	LOC(%rbx)
	fyl2x
	fstpl	LOC(%rdx)
	EPILOG(ylogx)

	PROLOG(sincos)
	fldl	LOC(%rax)
	fsincos
	fstpl	LOC(%rdx)
	fstpl	LOC(%rdx)
	EPILOG(sincos)

	PROLOG(exp)
	fldl	LOC(%rax)
	f2xm1
	fstpl	LOC(%rdx)
	EPILOG(exp)

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.ident	"David Harper at www.obliquity.com"
