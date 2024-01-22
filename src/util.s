# -*-
# Attempeux Jan 21 2024.
# Helper functions.
# -*-

.section .text

.globl  fx_isalpha
.globl  fx_tolower
.globl  fx_strlen
.globl  fx_ismorse
.globl fx_cmpstrs
.globl fx_memzero

# @function.
# The current character is alpabetic?
# Arguments: current character.
# Return: 0 if it is not.
#         1 if it is.
#         2 if it is a space.
fx_isalpha:
    cmpl    $' ', %edi
    jz      fx_isalpha_space
    cmpl    $64, %edi
    jbe     fx_isaplha_not
    cmpl    $90, %edi
    jbe     fx_isaplha_yes
    cmpl    $96, %edi
    jbe     fx_isaplha_not
    cmpl    $123, %edi
    jae     fx_isaplha_not
    jmp     fx_isaplha_yes
fx_isalpha_space:
    movl    $2, %eax
    jmp     fx_isalphafini
fx_isaplha_yes:
    movl    $1, %eax
    jmp     fx_isalphafini
fx_isaplha_not:
    movl    $0, %eax
fx_isalphafini:
    ret

# @function.
# Parse the current slphabetic character to its
# lower versionn.
# Arguments: Current character.
# Return: I think i alredy said it...
fx_tolower:
    cmpl    $97, %edi
    jae     fx_tolowerfini
    addl    $32, %edi
fx_tolowerfini:
    movl    %edi, %eax
    ret

# @function.
# Return the length of the string i give u.
# Argumments: String for which you wanna determine the size.
# Return: The size.
fx_strlen:
    movq    %rdi, %r9
    movq    $0, %r10
fx_strlen_eat:
    movzbl  (%r9), %eax
    cmpl    $0, %eax
    jz      fx_strlenfini
    incq    %r9
    incq    %r10
    jmp     fx_strlen_eat
fx_strlenfini:
    movq    %r10, %rax
    ret

# @function.
# Checks if the current character is valid as a morse mnemonic. 
# Argumments: Character to be evaluated.
# Return: 0 if is not.
#         1 if it is.
fx_ismorse:
    cmpl    $'.', %edi
    jz      fx_ismorse_yes
    cmpl    $'-', %edi
    jz      fx_ismorse_yes
    movl    $0, %eax
    jmp     fx_ismorsefini
fx_ismorse_yes:
    movl    $1, %eax
fx_ismorsefini:
    ret

# @function.
# GCC always helping. strcmp function (the one found in C).
# Argumments: string 1 and string 2.
# Return: 0 if is they're equal.
#         1 if it they are not.
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

# @function.
# Fills all bytes of the current code with zeros.
# Arguments: Address where the code is stored.
# Return: None.
fx_memzero:
    movq    $0, %rbx
fx_memzeroset:
    cmpq    $4, %rbx
    jz      fx_memzerofini
    movb    $0, (%rdi, %rbx)
    inc     %rbx
    jmp     fx_memzeroset
fx_memzerofini:
    ret
