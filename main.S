# ---------------------------------------------------#
# File created by Attempeux on Jan 15 2023 program.  #
# Main file to mo-asm program.                       #
# ---------------------------------------------------#
.text
.section .rodata

    .str_usage:
    .string "mo-asm: usage: %s [mode] [message].\n\tmode: [M | T]\n\tmessage to translate.\n"

    .err_unknown_mode:
    .string "mo-asm: error: unknown mode: %c.\n"

    .print_morse:
    .string "%s "

    # --- Morse codes.
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

.text
.globl main

# --- (F) Main function.
#       -4(%rbp): Saves number of arguments.
#       -12(%rbp): Saves the arguments.
#       -20(%rbp): Mode to use.
#       -28(%rbp): Message to convert.
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    movl    %edi, -4(%rbp)
    movq    %rsi, -12(%rbp)
    cmpl    $3, -4(%rbp)
    jne     no_args

    movq    -12(%rbp), %rax
    movq    8(%rax), %rax
    movq    %rax, -20(%rbp)
    movq    -12(%rbp), %rax
    movq    16(%rax), %rax
    movq    %rax, -28(%rbp)

    movq    -20(%rbp), %rax
    movq    %rax, %rdi
    movzbl  (%rax), %eax
    cmpb    $'T', %al
    jne     no_text_to_morse

    movq    -28(%rbp), %rdi
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
    movq    -28(%rbp), %rdi
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
    movl    $10, %edi
    call    putchar
    movl    $0, %eax
    leave
    ret

# --- (F): Function to translate from text to morse.
#         -8(%rbp): String to be converted.
#         -16(%rbp): Size of such string.
#         -24(%rbp): aka i.
text_to_morse:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp
    movq    %rdi, -8(%rbp)
    movq    -8(%rbp), %rax
    movq    %rax, %rdi
    call    strlen
    movq    %rax, -16(%rbp)
    movq    $0, -24(%rbp)
    jmp     __loopcond

# --- (L): Since the conditional checks for alpaha characters only it would
#          throw error for space, so it is a special case.
__print_space:
    movl    $'/', %edi
    call    putchar
    movl    $' ', %edi
    call    putchar
    jmp     __continue

__is_not_alpha:
    cmpl    $' ', %r8d
    je      __print_space
    movl    %r8d, %edi
    call    putchar
    jmp     __continue

# --- (L): Get the current character and try to parse it to morse code.
#          %r8d: gonna save the current character.
__loopbody:
    movq    -8(%rbp), %rdx
    movq    -24(%rbp), %rax
    addq    %rdx, %rax
    movzbl  (%rax), %r8d
    movl    %r8d, %edi
    movl    %r8d, %edi
    call    isalpha
    cmpl    $0, %eax
    je      __is_not_alpha
    movl    %r8d, %edi
    call    tolower
    subl    $'a', %eax
	leaq	0(,%rax,8), %rdx
	leaq	.morse_codes(%rip), %rax
	movq	(%rdx,%rax), %rax
	movq	%rax, %rsi
    leaq    .print_morse(%rip), %rdi
	call	printf

__continue:
    incq    -24(%rbp)

# --- (L): As long as there's characters this label will be reached.
__loopcond:
    movq    -24(%rbp), %rax
    cmpq    -16(%rbp), %rax
    jl      __loopbody
    nop
    leave
    ret

# --- (F): Function to translate from morse to text.
#         -8(%rbp): String to parse.
#         -16(%rbp): Length of the string.
#         -24(%rbp): Current position of the string aka i.
#         -28(%rbp): Nth character of the current code.
#         -[29..33](%rbp): Current morse code.
#         -38(%rbp): Looking for the translation index aka j.
morse_to_text:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $48, %rsp
    movq    %rdi, -8(%rbp)
    movq    -8(%rbp), %rax
    movq    %rax, %rdi
    call    strlen
    movq    %rax, -16(%rbp)
    movl    $0, -28(%rbp)
    movl    $0, -33(%rbp)
    jmp     _loopcond

# --- (L): Print the current code as text.
_print_such:
    movl    -38(%rbp), %edi
    addl    $'a', %edi
    call    putchar
    jmp     _end_eval

# --- (L): Try to find the correct translation.
_look_for_translation_body: 
    movl    -38(%rbp), %eax
    cltq
	leaq	0(,%rax,8), %rdx
	leaq	.morse_codes(%rip), %rax
	movq	(%rdx, %rax), %rax
	movq	%rax, %rdi
    leaq    -33(%rbp), %rsi
    movq    -28(%rbp), %rdx
    call    strcmp
    cmpq    $0, %rax
    je      _print_such
    incl    -38(%rbp)

# --- (L): Just itering.
_look_for_translation_condition:
    cmpl    $26, -38(%rbp)
    jl      _look_for_translation_body

# --- (L): Sets all to zero and continues the main loop
#          looking for more codes.
_end_eval:
    leaq    -33(%rbp), %rdi
    movq    $0, %rsi
    movq    $4, %rdx
    call    memset
    movl    $0, -28(%rbp)
    movl    $0, -38(%rbp)
    jmp     _continue

# --- (L): If the current character is a space or the nth chracter is equals to
#          four then it means there's already a code to be evaluated.
_evaluate: 
    cmpl    $0, -28(%rbp)
    je      _continue
    jmp     _look_for_translation_condition

# --- (L): If the current character is a '/' it means a space in normal text.
_print_space:
    movl    $' ', %edi
    call    putchar
    jmp     _continue

_loopbody: 
    movq    -8(%rbp), %rax
    movq    -24(%rbp), %rdx
    addq    %rdx, %rax
    movzbl  (%rax), %eax
    cmpl    $'/', %eax
    je      _print_space
    cmpl    $' ', %eax
    je      _evaluate
    cmpl    $4, -28(%rbp)
    je      _evaluate
    movl    %eax, %edx
    movl    -28(%rbp), %eax
    movb    %dl, -33(%rbp, %rax)
    incl    -28(%rbp)

_continue:
    incq    -24(%rbp)

_loopcond:
    movq    -24(%rbp), %rax
    cmpq    -16(%rbp), %rax
    jle     _loopbody
    nop
    leave
    ret
