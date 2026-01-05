.include "./files/utility.s"

.data
n_0: .byte 0
print_msg: .ascii "Numero iterazioni (k):\r"

.text

_main:
    nop

    call indecimal_byte
    mov %al, n_0
    mov $0, %ah
    call newline

check:
    cmp $1, %ax
    je print




print:
    lea print_msg, %ebx
    call outline
    movb k, %al
    call outdecimal_byte
    call newline