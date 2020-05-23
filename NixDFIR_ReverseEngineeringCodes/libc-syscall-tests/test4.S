	.globl	_main
_main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
## print
	movl	$4, %eax
	movl	$1, %ecx
	movl	$7, %edx

        xorb    %sil, %sil
        leaq    hello(%rip), %rdi
        movq    %rdi, -16(%rbp)
        movl    %eax, %edi
        movb    %sil, -17(%rbp)
        movl    %ecx, %esi
        movq    -16(%rbp), %rax
        movl    %edx, -24(%rbp)
        movq    %rax, %rdx
        movl    -24(%rbp), %ecx
        movb    -17(%rbp), %al

        callq   _syscall
        movl    $0, %eax
        addq    $32, %rsp
        popq    %rbp
        ret
## data
hello:
	.asciz	 "\nHello\n"
