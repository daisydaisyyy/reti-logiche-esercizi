.include "./files/utility.s"

.data
x: .byte 0
y: .byte 0
op_type: .byte 0
res_start: .ascii "= \r"
err_msg: .ascii "ERR\r"
.text

.globl _main


_main:
in_x:
    mov $0, %bl
    mov x, %dl
    call input
    cmpb $0, %bl
    je store_x
    neg %dl
store_x:
    movb %dl, x

in_sgn:
    movb $' ', %al
    call outchar
    call inchar
    movb %al, op_type
    call outchar
    movb $' ', %al
    call outchar
in_y:
    movb $0, %bl
    movb y, %dl
    call input
    cmpb $0, %bl
    je store_y
    neg %dl
store_y:
    movb %dl, y
    call newline
    movl $2, %ecx
    lea res_start, %ebx
    call outmess
    mov op_type, %al

cmp_op:
    cmpb $'+', %al
    je sum

    cmpb $'-', %al
    je diff
    
    cmpb $'*', %al
    je mult

    cmpb $'/', %al
    je divi
    
sum:
    movb y, %al
    cbw
    movw %ax, %bx
    movb x, %al
    cbw

    add %bx, %ax
    jmp end

diff:
    movb y, %al
    cbw
    movw %ax, %bx
    movb x, %al
    cbw

    sub %bx, %ax
    jmp end

mult:
    movb x, %al
    movb y, %bl
    imul %bl
    jmp end

divi:
    movb x, %al
    movb y, %bl
    cmp $0, %bl
    je error
    cbw
    idiv %bl
    cbw

end:
    mov %ax, %bx
    cmp $0, %bx
    jl neg_
    jmp pos

neg_: 
    mov $'-', %al
    call outchar
    neg %bx
    jmp res

pos:
    mov $'+', %al
    call outchar

res:
    mov %bx, %ax
    call outdecimal_word
    call newline
    call newline
    jmp in_x

error:
    lea err_msg, %ebx
    call outline
    ret


# function
input:
    call inchar
    cmpb $'-', %al
    je neg
    cmpb $'+', %al
    je in_num
    jmp input

neg:
    inc %bl

in_num:
    call outchar
    call indecimal_byte
    mov %al, %dl
    ret
