.include "./files/utility.s"


.data
n: .byte 0
v1: .fill 255
v2: .fill 255
msg_in: .ascii "Inserire n:\r"
msg_v1: .ascii "Inserire vettore v1:\r"
msg_v2: .ascii "Inserire vettore v2:\r"
msg_end: .ascii "Il prodotto scalare è:\r"


.text


.globl _main

_main:
    lea msg_in, %ebx
    call outline
    call indecimal_byte
    call newline
    cmp $0, %al
    je fine
    mov %al, n

start_v1:
    lea v1, %edi
    lea msg_v1, %ebx
    call start_fill


start_v2:
    lea v2, %edi
    lea msg_v2, %ebx
    call start_fill


prodotto:
    lea v1, %edi
    lea v2, %esi
    xor %eax, %eax
    xor %ebx, %ebx
    xor %ecx, %ecx
loop_prod:
    xor %eax, %eax
    lodsb
    mulb (%edi)
    inc %edi
    add %eax, %ebx
    inc %cl
    cmp n, %cl
    jne loop_prod


print_prod:
    mov %bl, %al
    lea msg_end, %ebx
    call outline
    call outdecimal_long
    call newline

fine:
    ret


# argomenti: ebx = messaggio da stampare, edi = vettore da riempire
start_fill:
    call outline
    movl n, %ecx

fill_v:
    call indecimal_byte
    mov %al, %bl
    mov $'\t', %al
    call outchar

store_v:
    cld
    mov %bl, %al
    stosb
    dec %cl
    cmp $0, %cl
    jne fill_v
    call newline
    ret





