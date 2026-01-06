.include "files/utility.s"

.data
x: .word 0
y: .word 0
msg_d: .ascii "dentro\r"
msg_f: .ascii "fuori\r"

.text

.globl _main

_main:
    call inword
    movw %ax, x
    call newline
    call inword
    movw %ax, y
    cmp $500, %ax
    jge fine
    cmpw $0, %ax
    je test0
    movw x, %ax
    cmpw $500, %ax
    jge fine
    jmp solve

test0:
    cmpw $0, %ax
    je fine

solve:
    movw x, %ax
    call testp

fine:
    ret

testp:
    call abs
    mov %ax, %bx
    mov y, %ax
    call abs
    mov %ax, %dx
    add %bx, %dx
    call newline
    cmpw $128, %dx
    ja fuori

    cmpw $64, %dx
    jb fuori


dentro:
    lea msg_d, %ebx
    call outline
    jmp fine
    ret

fuori:
    lea msg_f, %ebx
    call outline
    ret



abs:
    cmp $0, %ax
    jge abs_fine
    neg %ax

abs_fine:
    ret
