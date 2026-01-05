.include "./files/utility.s"

.data
msg_found: .ASCII "colpito!\r"
msg_missed: .ASCII "mancato!\r"
msg_win: .ASCII "vittoria!\r"

.text
.globl main

_main:
    # leggi stato iniziale
    call inword
    call newline
    mov %ax, %dx

check_win:
    # stampa vittoria e termina
    cmp $0, %dx
    jnz game_loop
    lea msg_win, %ebx
    call outline
    call newline
    ret
    
game_loop:
    # leggi bersaglio
    xor %ecx, %ecx
    call inletter
    mov %al, %cl
    shl $2, %cl
    call innumber
    add %al, %cl

    # stampa colpito
    mov $1, %ax
    shl %cl, %ax
    and %dx, %ax
    jnz found

    # torna al punto 2
    lea msg_missed, %ebx
    call outline
    jmp game_loop

found:
    lea msg_found, %ebx
    call outline
    # modifica stringa iniziale
    xor %ax, %dx
    jmp check_win

inletter:
    call inchar
    cmp $'a', %al
    jb inletter
    cmp $'d', %al
    ja inletter
    call outchar
    sub $'a', %al
    ret


innumber:
    call inchar
    cmp $'1', %al
    jb innumber
    cmp $'4', %al
    ja innumber
    call outchar
    call newline
    sub $'1', %al
    ret
