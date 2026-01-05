.include "./files/utility.s"

.data
n: .byte 0
v1: .fill 256,1,0
v2: .fill 256,1,0
res: .long 0
n_msg: .ascii "Inserire n:\r"
v1_msg: .ascii "Inserire vettore v1:\r"
v2_msg: .ascii "Inserire vettore v2:\r"
res_msg: .ascii "Il prodotto scalare è:\r"

.text

.globl _main


_main:
    lea n_msg, %ebx
    call outline
    call indecimal_byte
    mov %al, n
    call newline
    cmp $0, %al
    je end
in_v1:
    lea v1, %eax
    lea v1_msg, %ebx
    xor %ecx, %ecx
    call in_v
in_v2:
    lea v2, %eax
    lea v2_msg, %ebx
    xor %ecx, %ecx
    call in_v


solve:
    movzbl n, %ecx
    lea v1, %esi
    lea v2, %edi
    xorl %edx, %edx

solve_loop:
    xorl %eax, %eax 
    lodsb
    xorl %ebx, %ebx # stores product result
    movb (%edi), %bl
    inc %edi
    mulw %bx # max value (255*255) fits in ax, so no need to check dx
    movzwl %ax, %eax
    addl %eax, res
    loop solve_loop
end:
    lea res_msg, %ebx
    call outline
    mov res, %eax
    call outdecimal_long
    ret


in_v:
    call outline
    mov %eax, %ebx
in_loop:
    cmp %cl, n
    je end_v
    call indecimal_byte
    mov %al, (%ebx)
    call newline
    inc %cl
    inc %ebx
    jmp in_loop

end_v:
    ret
