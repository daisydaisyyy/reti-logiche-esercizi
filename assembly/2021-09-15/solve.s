.include "./files/utility.s"

.data
    s: .fill  80,1
    counter: .fill 16,1,0
.text


_main:
start:
    lea s, %ebx
    mov $80,%ecx
    call inline

    mov $16, %ecx
    lea counter, %edi

loop_reset:
    movb $0, (%edi)
    inc %edi
    loop loop_reset

    lea s, %esi
    lea counter, %edi
    xor %edx, %edx 
    xor %eax, %eax
scan:
    mov (%esi), %al
    cmp $0x0d, %al
    jne read_letter
    mov $0, %ecx
    lea s, %esi
    lea counter, %edi

print:
    cmpb $16, %cl
    je end
    cmpb $0, (%edi, %ecx)
    je print_end
    mov %cl, %al
    cmpb $9, %al
    ja print_hex
    add $'0', %al

print_out:
    inc %dl
    call outchar
    mov $' ', %al
    call outchar
    movb (%edi, %ecx), %al
    call outdecimal_byte
    call newline

print_end:
    inc %cl
    jmp print

end:
    call newline
    cmpb $0, %dl
    jne start
    ret

print_hex:
    sub $10, %al
    add $'a', %al
    jmp print_out

cmp_hex_1:
    cmp $'a', %al
    jb cmp_hex_2
    cmp $'f', %al
    ja cmp_hex_2
    sub $'a', %al
    add $10, %al
    jmp inc_counter

cmp_hex_2:
    cmp $'A', %al
    jb skip
    cmp $'F', %al
    ja skip
    sub $'A', %al
    add $10, %al
    jmp inc_counter

read_letter:
    # controllo validita'
    cmp $'0', %ax
    jb skip
    cmp $'9', %ax
    ja cmp_hex_1
    sub $'0', %al

inc_counter:
    and $0xff, %ax
    incb (%edi, %eax)
    
skip:
    inc %esi
    jmp scan
