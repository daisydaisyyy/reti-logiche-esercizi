.include "./files/utility.s"

.data
a:      .long 0
b:      .word 0
r:      .word 0
q:      .word 0
abs_a:  .long 0
abs_b:  .long 0 

sgn_q:  .byte 0
sgn_r:  .byte 0

abs_q:  .word 0
abs_r:  .word 0
msg_nodiv: .ascii "NO DIV\r"

.text
.globl _main

_main:
    call inlong
    call newline
    movl %eax, a

    call inword
    call newline
    movw %ax, b

    xorl %ecx, %ecx   
    xorl %edx, %edx   
    
    movl a, %eax
    testl %eax, %eax
    jge a_pos
    negl %eax
    incb %cl         
    incb %dl           
a_pos:
    movl %eax, abs_a
    movb %dl, sgn_r

    movswl b, %eax      # estendi b a 32 bit
    testl %eax, %eax
    jge b_pos
    negl %eax
    incb %cl       
b_pos:
    movl %eax, abs_b
    andb $1, %cl       
    movb %cl, sgn_q

    movl abs_a, %eax    
    movl abs_b, %ebx    
    xorl %ecx, %ecx     

    cmpl $0, %ebx  
    je no_div

div_loop:
    cmpl %ebx, %eax
    jl end_loop
    subl %ebx, %eax
    incl %ecx
   
    cmpl $32768, %ecx
    jae no_div
    jmp div_loop

end_loop:
    movw %ax, abs_r
    movw %cx, abs_q

    movw abs_q, %ax
    cmpb $1, sgn_q
    jne apply_r
    negw %ax
apply_r:
    movw %ax, q

    movw abs_r, %ax
    cmpb $1, sgn_r
    jne print
    negw %ax
print:
    movw %ax, r
    
    movw q, %ax
    call outword
    call newline
    movw r, %ax
    call outword
    call newline
    ret

no_div:
    lea msg_nodiv, %ebx
    call outline
    ret