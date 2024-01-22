# -*-
# Attempeux Jan 21 2024.
# moasm's starting point.
# -*-

.section  .rodata
    .str_usage:
    .string "moasm: usage: ./moasm [mode] [msg].\n"

    .str_constant_chars:
    .string "abcdefghijklmnopqrstuvwxyz/ \n"

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

    .str_usage_len:
    .long 37

    .offset_4_newline:
    .quad   28

    .offset_4_ascii_space:
    .quad   27

    .offset_4_morse_space:
    .quad   26

.section    .text
.globl      _start

.extern     fx_isalpha
.extern     fx_tolower
.extern     fx_strlen
.extern     fx_ismorse
.extern     fx_cmpstrs
.extern     fx_memzero

# @function.
# Prints a portion of .str_constant_chars.
# Arguments: Bytes to be printed (r10), offset (r9).
# Return: None.
.helper_print:
    leaq    .str_constant_chars(%rip), %rsi
    addq    %r9, %rsi
    movq    %r10, %rdx
    movq    $1, %rax
    movq    $1, %rdi
    syscall
    ret

# @function.
# Main function somehow.
# Arguments: argc argv we all know what they are.
# Return: 0 on success.
#         1 on failure.
_start:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    8(%rbp), %rax
    cmpq    $3, %rax
    jnz     _start_usage
    movq    32(%rbp), %rdi
    movq    24(%rbp), %rax
    movzbl  (%rax), %eax
    cmpl    $'T', %eax
    jnz     _start_check_for_mmode
    call    fx_t_mode

_start_end:
    movq    .offset_4_newline, %r9
    movq    $1, %r10
    call    .helper_print
    movq    $0, %rdi
    jmp     _start_fini

_start_usage:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    .str_usage(%rip), %rsi
    movq    .str_usage_len(%rip), %rdx
    syscall
    movq    $1, %rdi

_start_fini:
    movq    $60, %rax
    syscalL

_start_check_for_mmode:
    cmpl    $'M', %eax
    jnz     _start_usage
    call    fx_m_mode
    jmp     _start_end

# @function.
# T mode was selected -> Text to morse process.
# Arguments: mesage to be translated.
# Return: None.
fx_t_mode:
    movq    %rdi, %r8
    jmp     fxT_evalchar
fxT_eatchar:
    incq    %r8
fxT_evalchar:
    movzbl  (%r8), %eax
    cmpl    $0, %eax
    jz      fxT_fini
    movl    %eax, %edi
    call    fx_isalpha
    cmpl    $1, %eax
    jz      fxT_print_as_morse
    cmpl    $2, %eax
    jz      fxT_print_space
    movq    $1, %rax
    movq    $1, %rdi
    movq    %r8, %rsi
    movq    $1, %rdx
    syscall
    jmp     fxT_eatchar

fxT_print_as_morse:
    # Get the lower version of the current character and the subtract 'a'
    # from it to get the index of the letter e.g. 'h' - 'a' = 7. 'h' is the
    # 8th letter in the alphabet but remember, we start from zero.
    movzbl  (%r8), %edi
    call    fx_tolower
    subl    $97, %eax
    leaq    0(, %rax, 8), %rbx
    leaq    .morse_codes(%rip), %rax
    movq    (%rbx, %rax), %rsi
    movq    %rsi, %rdi
    call    fx_strlen
    movq    %rax, %rdx
    movq    $1, %rax
    movq    $1, %rdi
    syscall
    movq    .offset_4_ascii_space, %r9
    movq    $1, %r10
    call    .helper_print
    jmp     fxT_eatchar

fxT_print_space:
    movq    .offset_4_morse_space, %r9
    movq    $2, %r10
    call    .helper_print
    jmp     fxT_eatchar

fxT_fini:
    ret

# @function.
# M mode was selected -> Morse to text process.
# Arguments: mesage to be translated.
# Return: None.
fx_m_mode:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    movq    %rdi, %r8
    # Stack layout for this function ----------------------------------------------
    # Array of characters to save the current code.                               ~ -4(%rbp)
    # Marks where to set the current char of the code aka code[i] = something.    ~ -8(%rbp)
    # Compare the current code with morsecode[j] aka j.                           ~ -12(%rbp)
    # -----------------------------------------------------------------------------
    movb    $0, (%rbp)
    movl    $0, -4(%rbp)
    movl    $0, -8(%rbp)
    movl    $0, -12(%rbp)
    jmp     fxM_evalchar

fxM_eat:
    incq    %r8

fxM_evalchar:
    movzbl  (%r8), %eax
    cmpl    $0, %eax
    jz      fxM_fini
    movl    %eax, %edi
    call    fx_ismorse
    cmpl    $1, %eax
    jz      fxM_savechar
    cmpl    $'/', %edi
    jz      fxM_printspace
    cmpl    $' ', %edi
    jz      fxM_evalcode
    movq    $1, %rax
    movq    $1, %rdi
    movq    %r8, %rsi
    movq    $1, %rdx
    syscall
    jmp     fxM_eat

fxM_savechar:
    cmpl    $4, -8(%rbp)
    jz      fxM_evalcode
    movb    (%r8), %dl
    movl    -8(%rbp), %eax
    movb    %dl, -4(%rbp, %rax)
    incl    -8(%rbp)
    jmp     fxM_eat

fxM_printspace:
    movq    .offset_4_ascii_space, %r9
    movq    $1, %r10
    call    .helper_print
    jmp     fxM_eat

fxM_evalcode:
    cmpl    $25, -12(%rbp)
    jz      fxM_clear
    leaq    -4(%rbp), %rdi
    movl    -12(%rbp), %eax
    leaq    0(, %rax, 8), %rbx
    leaq    .morse_codes(%rip), %rax
    movq    (%rbx, %rax), %rsi
    call    fx_cmpstrs
    movl    $0, %eax
    jz      fxM_codefound
    incl    -12(%rbp)
    jmp     fxM_evalcode

fxM_codefound:
    movl    -12(%rbp), %r9d
    movq    $1, %r10
    call    .helper_print

fxM_clear:
    movl    $0, -8(%rbp)
    movl    $0, -12(%rbp)
    leaq    -4(%rbp), %rdi
    call    fx_memzero
    jmp     fxM_eat

fxM_fini:
    leave
    ret
