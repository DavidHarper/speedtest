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
	
        cmp     $0,%r9d
        je      .Lnop
	
        cmp     $1,%r9d
        je      .Ladd
	
        cmp     $2,%r9d
        je      .Lmultiply
	
        cmp     $3,%r9d
        je      .Ldivide
	
        cmp     $4,%r9d
        je      .Lcosine
	
        cmp     $5,%r9d
        je      .Lsqrt
	
        cmp     $6,%r9d
        je      .Latan
	
        cmp     $7,%r9d
        je      .Lylogx
	
        cmp     $8,%r9d
        je      .Lsincos
	
        cmp     $9,%r9d
        je      .Lexp

/	mode lies outside the range, so exit
	ret

	
	.align	4
.Lnop:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LnopOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LnopInnerLoop:
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LnopInnerLoop

	dec	%r8d
	jnz	.LnopOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Ladd:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LaddOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LaddInnerLoop:
	fldl	(%rax)
	faddl	(%rbx)
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LaddInnerLoop

	dec	%r8d
	jnz	.LaddOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lmultiply:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LmultiplyOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LmultiplyInnerLoop:
	fldl	(%rax)
	fmull	(%rbx)
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LmultiplyInnerLoop

	dec	%r8d
	jnz	.LmultiplyOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Ldivide:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LdivideOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LdivideInnerLoop:
	fldl	(%rax)
	fdivrl	(%rbx)
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LdivideInnerLoop

	dec	%r8d
	jnz	.LdivideOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lcosine:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LcosineOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LcosineInnerLoop:
	fldl	(%rax)
	fcos
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LcosineInnerLoop

	dec	%r8d
	jnz	.LcosineOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lsqrt:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LsqrtOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LsqrtInnerLoop:
	fldl	(%rax)
	fsqrt
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LsqrtInnerLoop

	dec	%r8d
	jnz	.LsqrtOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Latan:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LatanOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LatanInnerLoop:
	fldl	(%rax)
	fldl	(%rbx)
	fpatan
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LatanInnerLoop

	dec	%r8d
	jnz	.LatanOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lylogx:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LylogxOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LylogxInnerLoop:
	fldl	(%rax)
	fldl	(%rbx)
	fyl2x
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LylogxInnerLoop

	dec	%r8d
	jnz	.LylogxOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lsincos:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LsincosOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LsincosInnerLoop:
	fldl	(%rax)
	fsincos
	fstpl	(%rdx)
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LsincosInnerLoop

	dec	%r8d
	jnz	.LsincosOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

	
	.align	4
.Lexp:
	mov	%rdi,%r9
	mov	%rsi,%r10
	mov	%rdx,%r11

	movl	%ecx,%edi

	mov	%rbx,%rsi

.LexpOuterLoop:
	movl	%edi,%ecx

	mov	%r9,%rax
	mov	%r10,%rbx
	mov	%r11,%rdx

.LexpInnerLoop:
	fldl	(%rax)
	f2xm1
	fstpl	(%rdx)
	
	add	$8,%rax
	add	$8,%rbx
	add	$8,%rdx

	loop	.LexpInnerLoop

	dec	%r8d
	jnz	.LexpOuterLoop

	mov	%rsi,%rbx

	mov	$1,%rax

	ret

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
