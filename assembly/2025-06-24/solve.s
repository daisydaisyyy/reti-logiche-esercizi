.include  "./files/utility.s"

.data
n: .byte 0
sum: .long 0
diag: .byte 0
msg_n: .ascii "Inserire n: \r"
msg_mat: .ascii "Inserire matrice: \r"
msg_nondomin: .ascii "La matrice non è diagonalmente dominante.\r"
msg_domin: .ascii "La matrice è diagonalmente dominante.\r"

.text


_main:
    lea msg_n, %ebx
    call outline
    xor %eax, %eax
    xor %edi, %edi
    call indecimal_byte
    cmpb $0, %al
    je fine
    mov %al, n
    xorl  %ecx, %ecx
    xorl %edx, %edx
    # ecx riga, edx colonna
    call newline
    lea msg_mat, %ebx
    call outline
solve:
    cmpb n, %cl
    je solve_end
    cmpb n, %dl
    jne input
    # fine riga
    # controllo dominanza
    mov sum, %esi
    xor %ebx, %ebx
    mov diag, %bl
cmp_check:
    cmp %esi, %ebx
    jae next_row
    inc %di
    # cambio riga
next_row:
    call newline
    xorb %dl, %dl
    inc %cl
    movl $0, sum
    movb $0, diag
    cmpb n, %cl
    je solve_end
input:
    xor %eax, %eax
    call indecimal_byte

    # controllo se sommare o se ho l'elem diag
    cmpb %dl,%cl
    je store_diag
    add %eax, sum
   
    jmp solve_loop

store_diag:
    mov %al, diag

solve_loop:
    incb %dl

    mov $'\t', %al
    call outchar
    
    jmp solve

solve_end:
    cmp $0, %di
    je domin

non_domin:
    lea msg_nondomin, %ebx
    jmp print

domin:
    lea msg_domin, %ebx

print:
    call outline

fine:
    ret
