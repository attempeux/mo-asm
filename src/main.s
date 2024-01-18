# ---------------------------------------------------#
# File created by Attempeux on Jan 15 2024 program.  #
# Main file to mo-asm program.                       #
# ---------------------------------------------------#
.section .rodata
    .str_usage:
    .string "mo-asm: usage: ./noasm [mode] [message].\n\tmode: [M | T]\n\tmessage to translate.\n"

    .str_unknown_mode:
    .string "mo-asm: error: argument one is a unknown mode.\n"

    .str_morse_space:
    .string "/ "

    .Ma: .string ".-"
    .Mb: .string "-..."
    .Mc: .string "-.-."
    .Md: .string "-.."
    .Me: .string "."
    .Mf: .string "..-."
    .Mg: .string "--."
    .Mh: .string "...."
    .Mi: .string ".."
    .Mj: .string ".---"
    .Mk: .string "-.-"
    .Ml: .string ".-.."
    .Mm: .string "--"
    .Mn: .string "-." 
    .Mo: .string "---"
    .Mp: .string ".--."
    .Mq: .string "--.-"
    .Mr: .string ".-."
    .Ms: .string "..."
    .Mt: .string "-"
    .Mu: .string "..-"
    .Mv: .string "...-"
    .Mw: .string ".--"
    .Mx: .string "-..-"
    .My: .string "-.--"
    .Mz: .string "--.."

	.section    .data.rel.local, "aw"
    .align      32
    .size       .morse_codes, 208
    .morse_codes:
    .quad   .Ma
    .quad   .Mb
    .quad   .Mc
    .quad   .Md
    .quad   .Me
    .quad   .Mf
    .quad   .Mg
    .quad   .Mh
    .quad   .Mi
    .quad   .Mj
    .quad   .Mk
    .quad   .Ml
    .quad   .Mm
    .quad   .Mn
    .quad   .Mo
    .quad   .Mp
    .quad   .Mq
    .quad   .Mr
    .quad   .Ms
    .quad   .Mt
    .quad   .Mu
    .quad   .Mv
    .quad   .Mw
    .quad   .Mx
    .quad   .My
    .quad   .Mz

.section .data
    .str_usage_len:
    .long 79

    .str_unknown_mode_len:
    .long 48

.section .text

# -*---------------------------------#
# Functions defined on help.s file.  #
# -*---------------------------------#
.extern fx_strlen
.extern fx_isalpha
.extern fx_2lower
.extern fx_cmpstrs
.extern fx_strncmp

.globl _start

_start:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    # -*---------------------------------#
    # Checking for arguments.            #
    # -*---------------------------------#
    movl    8(%rbp), %eax
    cmpl    $3, %eax
    jne     no_args_exit
    # -*---------------------------------#
    # Saving values into the stack.      #
    # -*---------------------------------#
    movq    24(%rbp), %rax
    movq    %rax, -8(%rbp)
    movq    32(%rbp), %rax
    movq    %rax, -16(%rbp)
    # -*---------------------------------#
    # Figure out mode to use.            #
    # -*---------------------------------#
    movq    -8(%rbp), %rax
    movzbl  (%rax), %eax
    cmpl    $'T', %eax
    jne     check_for_other_mode
    movq    -16(%rbp), %rdi
    call    fx_t_2_m

# -*------------------------------------#
# Print new line and finish the program #
# -*------------------------------------#
fini_main:
    pushq   $'\n'
    movq    $1, %rax
    movq    $1, %rdi
    movq    %rsp, %rsi
    movq    $1, %rdx
    syscall
    movq    $60, %rax
    movq    $0, %rdi
    syscall

# -*------------------------------------#
# Exit the program, cannot proceed.     #
# -*------------------------------------#
no_args_exit:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    .str_usage(%rip), %rsi
    movq    .str_usage_len(%rip), %rdx
    syscall
    movq    $60, %rax
    movq    $1, %rdi
    syscall

# -*------------------------------------#
# If it's not T maybe it's M (?).       #
# -*------------------------------------#
check_for_other_mode:
    cmpl    $'M', %eax
    jne     unknown_mode
    movq    -16(%rbp), %rdi
    call    fx_m_2_t
    jmp     fini_main

# -*------------------------------------#
# What tf did u type; exit...           #
# -*------------------------------------#
unknown_mode:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    .str_unknown_mode(%rip), %rsi
    movq    .str_unknown_mode_len(%rip), %rdx
    syscall
    movq    $60, %rax
    movq    $1, %rdi
    syscall

# -*------------------------------------#
# Text to morse (T mode)                #
# -*------------------------------------#
fx_t_2_m:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    %rdi, %r8
    jmp     fx_t2m_eval_char

# -*------------------------------------#
# Get next character.                   #
# -*------------------------------------#
fx_t2m_inc:
    incq    %r8

# -*------------------------------------#
# Evaluate current character.           #
# -*------------------------------------#
fx_t2m_eval_char:
    movq    %r8, %r10
    cmpb    $0, (%r8)
    je      fini_t2m
    # -*---------------------------------------#
    # Non-alpha chars are printed as they are. #
    # -*---------------------------------------#
    movzbl  (%r8), %edi
    call    fx_isalpha
    cmpl    $0, %eax
    je      fx_print_nonalpha
    # -*---------------------------------------#
    # Get index of current character.          #
    # -*---------------------------------------#
    call    fx_2lower
    subl    $'a', %eax
    leaq    0(, %rax, 8), %rdx
    leaq    .morse_codes(%rip), %rax
    movq    (%rdx, %rax), %rsi
    movq    %rsi, %rdi
    call    fx_strlen
    movq    %rax, %rdx
    movq    $1, %rax
    movq    $1, %rdi
    syscall
    pushq   $' '
    movq    $1, %rax
    movq    $1, %rdi
    movq    %rsp, %rsi
    movq    $1, %rdx
    syscall
    popq    %rax
    movq    %r10, %r8
    jmp     fx_t2m_inc

# -*---------------------------------------#
# Voila, c'est fini!                       #
# -*---------------------------------------#
fini_t2m:
    leave
    ret

# -*---------------------------------------#
# Print non-alpha one.                     #
# -*---------------------------------------#
fx_print_nonalpha:
    cmpb    $' ', (%r8)
    je      fx_printspace
    movq    $1, %rax
    movq    $1, %rdi
    movq    %r8, %rsi
    movq    $1, %rdx
    syscall
    jmp fx_t2m_inc

# -*---------------------------------------#
# Spaces are '/' character in morse.       #
# -*---------------------------------------#
fx_printspace:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    .str_morse_space(%rip), %rsi
    movq    $2, %rdx
    syscall
    jmp     fx_t2m_inc

# -*---------------------------------------#
# Getting ready to parse message.          #
# -*---------------------------------------#
fx_m_2_t:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp
    movq    %rdi, %r8
    movl    $0, -4(%rbp)
    movb    $0, -12(%rbp)
    movl    $0, -16(%rbp)
    movl    $0, -20(%rbp)
    jmp     fx_m2t_collect

# -*---------------------------------------#
# Get next one; r8++;                      #
# -*---------------------------------------#
fx_m2t_getnext1:
    incq    %r8

# -*---------------------------------------#
# Eating chars til get a code.             #
# -*---------------------------------------#
fx_m2t_collect:
    movq    %r8, %r15
    cmpb    $0, (%r8)
    je      fini_m2t
    # -*---------------------------------------#
    # Is it a morse-space?                     #
    # -*---------------------------------------#
    cmpb    $'/', (%r8)
    je      fx_m2t_printspace
    # -*---------------------------------------#
    # The current code is finished?            #
    # -*---------------------------------------#
    cmpb    $' ', (%r8)
    je      fx_m2t_translate
    # -*---------------------------------------#
    # The maximum len for a code is 4 bytes.   #
    # -*---------------------------------------#
    cmpl    $4, -4(%rbp)
    je      fx_m2t_translate
    # -*---------------------------------------#
    # Save the current char to build the code. #
    # -*---------------------------------------#
    movb    (%r8), %dl
    movl    -4(%rbp), %eax
    movb    %dl, -16(%rbp, %rax)
    # -*---------------------------------------#
    # Go for the next one! Allez!!!!           #
    # -*---------------------------------------#
    incl    -4(%rbp)
    movq    %r15, %r8
    jmp     fx_m2t_getnext1

# -*---------------------------------------#
# Tout est fini.                           #
# -*---------------------------------------#
fini_m2t:
    leave
    ret

# -*---------------------------------------#
# '/' is parsed as ' '.                    #
# -*---------------------------------------#
fx_m2t_printspace:
    pushq   $' '
    movq    $1, %rax
    movq    $1, %rdi
    movq    %rsp, %rsi
    movq    $1, %rdx
    syscall
    popq    %rax

# -*---------------------------------------#
# Comparing the current code with others.  #
# -*---------------------------------------#
fx_m2t_look:
    movl    -20(%rbp), %eax
    cltq
    leaq    0(,%rax, 8), %rdx
    leaq    .morse_codes(%rip), %rax
    movq    (%rdx, %rax), %rax
    movq    %rax, %rsi
    leaq    -16(%rbp), %rdi
    call    fx_cmpstrs
    cmpq    $0, %rax
    je      fx_m2t_print
    incl    -20(%rbp)

# -*---------------------------------------#
# Loop til make a match.                   #
# -*---------------------------------------#
fx_m2t_translate:
    cmpl    $26, -20(%rbp)
    jl      fx_m2t_look

# -*---------------------------------------#
# Code already printed, get next one pls.  #
# -*---------------------------------------#
fx_m2t_done_this_code:
    leaq    -16(%rbp), %rdi
    call    fx_setmem
    movl    $0, -20(%rbp)
    movl    $0, -4(%rbp)
    jmp     fx_m2t_getnext1

# -*---------------------------------------#
# Print the code as alpabethic.            #
# -*---------------------------------------#
fx_m2t_print:
    movzbl  -20(%rbp), %eax
    addl    $'a', %eax
    pushq   %rax
    movq    $1, %rax
    movq    $1, %rdi
    movq    %rsp, %rsi
    movq    $1, %rdx
    syscall
    popq    %rax
    jmp     fx_m2t_done_this_code
