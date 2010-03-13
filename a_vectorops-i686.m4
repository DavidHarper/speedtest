/ Speed test routine
/
/ Author: David Harper at obliquity.com
/
/ C prototype:
/
/ void vectorOps(double *a, double *b, double *c, int nsize,
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
	
define(`CASE', `
        cmpl    $$1,%eax
        je      .L$2')

define(`PROLOG',`
	.align	4
.L$1:
	movl	24(%ebp),%ecx

.L$1OuterLoop:
	movl	%ecx,%esi

	movl	20(%ebp),%ecx
	movl	8(%ebp),%eax
	movl	12(%ebp),%ebx
	movl	16(%ebp),%edx

.L$1InnerLoop:')

define(`EPILOG',`
	addl	$`'8,%eax
	addl	$`'8,%ebx
	addl	$`'8,%edx

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

/	mode lies outside the range, so exit
	xorl	%eax,%eax
	jmp	.Lexit

	PROLOG(nop)
	EPILOG(nop)

	PROLOG(add)
	fldl	(%eax)
	faddl	(%ebx)
	fstpl	(%edx)
	EPILOG(add)

	PROLOG(multiply)
	fldl	(%eax)
	fmull	(%ebx)
	fstpl	(%edx)
	EPILOG(multiply)

	PROLOG(divide)
	fldl	(%eax)
	fdivrl	(%ebx)
	fstpl	(%edx)
	EPILOG(divide)

	PROLOG(cosine)
	fldl	(%eax)
	fcos
	fstpl	(%edx)
	EPILOG(cosine)

	PROLOG(sqrt)
	fldl	(%eax)
	fsqrt
	fstpl	(%edx)
	EPILOG(sqrt)

	PROLOG(atan)
	fldl	(%eax)
	fldl	(%ebx)
	fpatan
	fstpl	(%edx)
	EPILOG(atan)

	PROLOG(ylogx)
	fldl	(%eax)
	fldl	(%ebx)
	fyl2x
	fstpl	(%edx)
	EPILOG(ylogx)

	PROLOG(sincos)
	fldl	(%eax)
	fsincos
	fstpl	(%edx)
	fstpl	(%edx)
	EPILOG(sincos)

	PROLOG(exp)
	fldl	(%eax)
	f2xm1
	fstpl	(%edx)
	EPILOG(exp)

.Lexit:
/	Restore the saved registers
	popl	%ebx
	popl	%esi
/	Clear up the stack frame and return
	leave
	ret

.Lend:
	.size	vectorOps,.Lend-vectorOps

	.ident	"David Harper at www.obliquity.com"
