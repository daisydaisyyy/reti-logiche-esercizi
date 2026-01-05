.include "./files/utility.s"

.data
n: .fill 6,1,0
res_dec: .long 0
res: .fill 8, 1, '\r' # il risultato sta su al piu' m+1=7 cifre + carattere di termine stringa
.text

_main:
    movb $' ', %al
    call outchar
    lea n, %edi
    xor %ecx, %ecx
input_loop:
    cmpb $6, %cl 
    je solve

    call inchar
    cmpb $'0', %al
    jb input_loop
    cmpb $'4', %al
    ja input_loop
    call outchar
    subb $'0', %al
    mov %al, (%edi, %ecx)
    inc %cl
    jmp input_loop

solve:
    # into base 10
    lea n, %edi
    xor %eax, %eax
    xor %ebx, %ebx
    movl $6, %ecx

convert_b10:
    mov $5, %edx
    mull %edx
    movb (%edi), %bl
    addl %ebx, %eax
    
    inc %edi
    loop convert_b10

solve_mul:
    mov %eax, %ebx
    mov $2, %eax
    mull %ebx
    mov %eax, res_dec
    mov $6, %ecx
    mov res_dec, %eax
    lea res, %esi


set_base5:
    cmp $0, %cl
    jl print

    xor %edx, %edx
    movl $5, %ebx
    divl %ebx
    # resto in edx
    addl $'0', %edx
    movb %dl, (%esi, %ecx)
    dec %cl
    cmpl $0, %eax
    je print
    jmp set_base5

print:
    movl $0, %ecx
    call newline
    
print_loop:
    movb (%esi, %ecx), %al
    cmpb $'\r', %al
    je print_end
    call outchar
    inc %cl
    jmp print_loop

print_end:
    ret

