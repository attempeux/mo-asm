# ---------------------------------------------------#
# File created by Attempeux on Jan 15 2023 program.  #
# Main file to mo-asm program.                       #
# ---------------------------------------------------#

.text
.section .rodata
.str_usage:
    .string "mo-asm: usage: %s [mode] [message].\n\tmode: [m | t]\n\tmessage to translate.\n"

.text
.globl main
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    movl    %edi, -4(%rbp)
    movq    %rsi, -12(%rbp)

    cmpl    $2, -4(%rbp)
    jne     no_args

    movl    $0, %eax
    leave
    ret

# -- (L): No arguments were given to the program, therefore
#         print the usage and exit.
no_args:
    movq    -12(%rbp), %rax
    movq    (%rax), %rsi
    leaq    .str_usage(%rip), %rax
    movq    %rax, %rdi
    call    printf
    movl    $1, %eax
    leave
    ret
