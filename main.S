# ---------------------------------------------------#
# File created by Attempeux on Jan 15 2023 program.  #
# Main file to mo-asm program.                       #
# ---------------------------------------------------#

.text
.section .rodata

    .str_usage:
    .string "mo-asm: usage: %s [mode] [message].\n\tmode: [M | T]\n\tmessage to translate.\n"

    .err_unknown_mode:
    .string "mo-asm: unknown mode: %c.\n"

    .help1:
    .string "text to morse."

    .help2:
    .string "morse to text."


.text
.globl main



# --- (F) Main function.
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    # --- (I): Saving arguments aka argc and argv.
    movl    %edi, -4(%rbp)
    movq    %rsi, -12(%rbp)
    cmpl    $3, -4(%rbp)
    jne     no_args

    # --- (I): Saving the mode at -20(%rbp) and message at -28(%rbp)
    movq    -12(%rbp), %rax
    movq    8(%rax), %rax
    movq    %rax, -20(%rbp)
    movq    16(%rax), %rax
    movq    %rax, -28(%rbp)

    # --- (I): Figure out what operation perform.
    movq    -20(%rbp), %rax
    movzbl  (%rax), %eax
    cmpb    $'T', %al
    jne     no_text_to_morse
    call    text_to_morse
    jmp     leave_main


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

# --- (L): If mode is not 'T' program jumps here.
no_text_to_morse:
    cmpb    $'M', %al
    jne     no_known_mode
    call    morse_to_text
    jmp     leave_main

# --- (L): Unknown mode; report error.
no_known_mode: 
    movb    %al, %sil
    leaq    .err_unknown_mode(%rip), %rax
    movq    %rax, %rdi
    call    printf
    movl    $1, %eax
    leave
    ret

# --- (L): End main function once the program has finished.
leave_main:
    movl    $0, %eax
    leave
    ret

# --- (F): Function to translate from text to morse.
text_to_morse:
    pushq   %rbp
    movq    %rsp, %rbp
    leaq    .help1(%rip), %rdi
    call    puts
    leave
    ret

# --- (F): Function to translate from morse to text.
morse_to_text:
    pushq   %rbp
    movq    %rsp, %rbp
    leaq    .help2(%rip), %rdi
    call    puts
    leave
    ret
