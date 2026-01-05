.include "./files/utility.s"

.data
n: .byte 0
out_v: .fill 40, 4, 0
x: .byte 0
y: .byte 0

.text


_main:
    nop
input:
    call indecimal_byte

check_input:
    cmp $2, %al
    jb input
    cmp $40, %al
    jg input
    movb %al, n
    xor %ecx, %ecx
    movb n, %cl # counter


init_v:
    lea out_v, %edi
    xor %esi, %esi
    mov %esi, (%edi)
    add $4, %edi
    inc %esi
    mov %esi, (%edi)


setup:
    xor %eax, %eax
    xor %ebx, %ebx
    movb $1, %bl
    mov $1, %ecx

loop_f:
    inc %cl
    xor %edi, %edi
    movl %eax, %edi
    addl %ebx, %edi
    movl %ebx, %eax
    movl %edi, %ebx

store: # store edi
    movl %edi, out_v(,%ecx,4)
    cmp n, %cl
    jne loop_f
    movb n, %cl
    inc %cl
print:
    dec %ecx
    movl out_v(, %ecx, 4), %eax
    call newline
    call outdecimal_long
    cmp $0, %ecx
    jne print

    ret



