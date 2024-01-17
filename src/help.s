# ---------------------------------------------------#
# File created by Attempeux on Jan 17 2023 program.  #
# Helper file.                                       #
# ---------------------------------------------------#
.section .text

.globl  fx_strlen
.globl  fx_isalpha
.globl  fx_2lower
.globl  fx_cmpstrs
.globl  fx_setmem

# -*---------------------------------------#
# Calculates the length of a string.       #
# -*---------------------------------------#
fx_strlen:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    $0, %r8
fx_eatchar:
    cmpb    $0, (%rdi)
    je      fini_strlen
    incq    %r8
    incq    %rdi
    jmp     fx_eatchar
fini_strlen:
    movq    %r8, %rax
    leave
    ret

# -*---------------------------------------#
# Figures out if the char is alphabetic.   #
# -*---------------------------------------#
fx_isalpha:
    pushq   %rbp
    movq    %rsp, %rbp
    cmpl    $64, %edi
    jle     fx_isalpha_no
    cmpl    $123, %edi
    jge     fx_isalpha_no
    cmpl    $91, %edi
    jge     fx_isalpha_between
    cmpl    $122, %edi
    jle     fx_isalpha_yes
fx_isalpha_between:
    cmpl    $96, %edi
    jle     fx_isalpha_no
    jmp     fx_isalpha_yes
fx_isalpha_no:
    movl    $0, %eax
    leave
    ret
fx_isalpha_yes:
    movl    $1, %eax
    leave
    ret

# -*---------------------------------------#
# Parses the char to its lower version.    #
# -*---------------------------------------#
fx_2lower:
    pushq   %rbp
    movq    %rsp, %rbp
    cmpl    $'a', %edi
    jge     fini_2lower
    addl    $32, %edi
fini_2lower:
    movl    %edi, %eax
    leave
    ret

# -*---------------------------------------#
# Compares code with nth code found.       #
# strcmp but in assembly, not implemented  #
# by me.                                   #
# -*---------------------------------------#
fx_cmpstrs:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, -16(%rbp)
	jmp	.L2
.L4:
	addq	$1, -8(%rbp)
	addq	$1, -16(%rbp)
.L2:
	movq	-8(%rbp), %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	je	.L3
	movq	-8(%rbp), %rax
	movzbl	(%rax), %edx
	movq	-16(%rbp), %rax
	movzbl	(%rax), %eax
	cmpb	%al, %dl
	je	.L4
.L3:
	movq	-8(%rbp), %rax
	movzbl	(%rax), %edx
	movq	-16(%rbp), %rax
	movzbl	(%rax), %eax
	cmpb	%dl, %al
	setb	%al
	movzbl	%al, %edx
	movq	-16(%rbp), %rax
	movzbl	(%rax), %ecx
	movq	-8(%rbp), %rax
	movzbl	(%rax), %eax
	cmpb	%cl, %al
	setb	%al
	movzbl	%al, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	popq	%rbp
	ret

# -*---------------------------------------#
# Set all bytes of the current code to 0.  #
# -*---------------------------------------#
fx_setmem:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    $0, %rcx
fx_setmem_set:
    cmpq    $4, %rcx
    je      fini_setmem
    movb    $0, (%rdi, %rcx)
    incq    %rcx
    jmp     fx_setmem_set
fini_setmem:
    leave
    ret
