.include "./files/utility.s"

.data
n_0: .word 0
msg: .ascii "Numero iterazioni (k):\r"

.text


.globl _main


_main:
    xor %eax, %eax
    call indecimal_word
    movw %ax, n_0
    call newline
    xor %ebx, %ebx
check_parity:
    xor %ecx, %ecx
    movw %ax, %cx # store n corrente
    shr %ax
    jc odd

even:
    shr %cx
    jmp loop_end
odd:
    movw $3, %ax
    mulw %cx
    inc %ax

loop_end:
    call outdecimal_word
    call newline
    inc %bl
    cmp $1, %cx
    je end
    cmp $255, %bl
    je end
    jmp check_parity




end:
    movb %bl, %dl
    lea msg, %ebx
    call outline
    movb %dl, %al
    call outdecimal_word
    call newline
    ret
