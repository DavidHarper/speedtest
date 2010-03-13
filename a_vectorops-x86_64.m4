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
/ R9   saved value of *a
/ R10  saved value of *b
/ R11  saved value of *c
/ EDI  saved value of nsize
/ RSI  saved rbx
/
/ Within inner loop:
/
/ RAX  *a
/ RBX  *b
/ RDX  *c
/ ECX  loop counter
	
define(`CASE', `
        cmp     $$1,%r9d
        je      .L$2')

define(`PROLOG',`
	.align	4
.L$1:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.L$1OuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.L$1InnerLoop:')

define(`EPILOG',`
	add	$`'8,%rax
	add	$`'8,%rbx
	add	$`'8,%rdx

	loop	.L$1InnerLoop

	dec	%r8d
	jnz	.L$1OuterLoop

	mov	%rsi,%rbx

	mov	$`'1,%rax

	ret')

	.text

	.align	4
.globl	vectorOps
	.type	vectorOps,@function
vectorOps:

/	Test niters > 0
	testl	%ecx,%ecx
	jg	.L1

	movl	$.STR1,%eax
	movq	%rax,%rdi
	call	puts

	ret
.L1:

/	Test nsize > 0
	testl	%r8d,%r8d
	jg	.L2

	movl	$.STR2,%eax
	movq	%rax,%rdi
	call	puts

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
	fldl	(%rax)
	faddl	(%rbx)
	fstpl	(%rdx)
	EPILOG(add)

	PROLOG(multiply)
	fldl	(%rax)
	fmull	(%rbx)
	fstpl	(%rdx)
	EPILOG(multiply)

	PROLOG(divide)
	fldl	(%rax)
	fdivrl	(%rbx)
	fstpl	(%rdx)
	EPILOG(divide)

	PROLOG(cosine)
	fldl	(%rax)
	fcos
	fstpl	(%rdx)
	EPILOG(cosine)

	PROLOG(sqrt)
	fldl	(%rax)
	fsqrt
	fstpl	(%rdx)
	EPILOG(sqrt)

	PROLOG(atan)
	fldl	(%rax)
	fldl	(%rbx)
	fpatan
	fstpl	(%rdx)
	EPILOG(atan)

	PROLOG(ylogx)
	fldl	(%rax)
	fldl	(%rbx)
	fyl2x
	fstpl	(%rdx)
	EPILOG(ylogx)

	PROLOG(sincos)
	fldl	(%rax)
	fsincos
	fstpl	(%rdx)
	fstpl	(%rdx)
	EPILOG(sincos)

	PROLOG(exp)
	fldl	(%rax)
	f2xm1
	fstpl	(%rdx)
	EPILOG(exp)

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.section	.rodata

	.align	8
.STR1:
	.string	"niters was non-positive\n"

	.align	8
.STR2:
	.string	"nsize was non-positive\n"

	.ident	"David Harper at www.obliquity.com"
