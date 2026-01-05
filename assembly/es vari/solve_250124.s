.include "./files/utility.s"

.data
a: .long 0
b: .word 0

abs_a: .long 0
abs_b: .word 0

sgn_a: .byte 0
sgn_b: .byte 0

q: .long 0
r: .word 0

abs_q: .long 0
abs_r: .word 0

sgn_q: .byte 0
sgn_r: .byte 0


msg_nodiv: .ascii "NO DIV"

.text


_main:
# input
call inlong
call newline
mov %eax, a
xor %eax, %eax
call inword
call newline
mov %ax, b

# modulo, segno di a


# modulo, segno di b


# segno di q


# segno di r


# modulo q

# modulo r


no_idiv:
no_div:
    lea msg_nodiv, %ebx
    call outline


fine:
    ret
