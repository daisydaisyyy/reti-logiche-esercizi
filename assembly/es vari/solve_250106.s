.include "./files/utility.s"

#  s: nuova ricerca
#  n: continua la ricerca in corso partendo da dopo l'ultima occorrenza
#  f: termina

.data
array: .byte 0x1A, 0x47, 0x34, 0xC5, 0x9B, 0x02, 0x6D, 0x8E, 0x9B, 0x1D, 0x47, 0x60, 0x29, 0x3A, 0x9B, 0x11
n:     .byte 16

currentpos:  .long 0x0    # offset (0..n-1). NON indirizzo
currentitem: .byte 0x0
currentcount:.byte 0x0

msg_found: .ascii "Trovata occorrenza di\r\n"
msg_counter: .ascii "Conteggio attuale:\r\n"
msg_term:  .ascii "Scansione array terminata.\r\n"
msg_tot:   .ascii "Totale:\r\n"
msg_occ:   .ascii "occorrenze di\r\n"

.text
    nop

_main:
loop_input:
    call inchar
    cmp $'f', %al
    je do_fine
    cmp $'s', %al
    je do_start_s

    # se non è 's', controlla se possiamo usare 'n'
    movl currentpos, %ebx
    cmp $0, %ebx
    je loop_input         # se currentpos == 0 non c'è ricerca in corso -> ignora 'n'
    cmp $'n', %al
    jne loop_input
    call outchar
    call search
    jmp loop_input

do_start_s:
    call outchar
    call start_s
    jmp loop_input

do_fine:
    call outchar
    call newline
    ret


# start_s: avvia una nuova ricerca (legge il byte da cercare e azzera lo stato)
start_s:
    push %eax
    push %edi

    mov $' ', %al
    call outchar              # spazio prima dell'input
    call inbyte               # leggi il byte (es. "1A")
    movb %al, currentitem
    movl $0, currentpos       # offset = 0 (inizia dall'inizio)
    movb $0, currentcount     # azzera conteggio

    call search               # esegui la prima ricerca

    pop %edi
    pop %eax
    ret


# search: cerca la prossima occorrenza a partire da currentpos
search:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %edi

    call newline
    lea array, %ebx            # EBX = base array
    movb currentitem, %al      # AL = byte da cercare
    movl currentpos, %edx      # EDX = offset corrente
    movb n, %cl
    movzx %cl, %ecx            # ECX = n (numero totale elementi)
    subl %edx, %ecx            # ECX = elementi rimanenti = n - currentpos
    test %ecx, %ecx
    jz search_not_found        # se non rimane niente -> non trovato

    leal (%ebx,%edx,1), %edi   # EDI = base (ebx) + offset (edx) -> puntatore corrente
    cld
    repne scasb                # cerca AL in [EDI..]; ECX decresce, EDI punta al byte DOPO l'occorrenza se trovato

    jnz search_not_found       # se ZF==0 -> non trovato

    # ---------- trovato ----------
    incb currentcount          # incremento contatore

    # aggiorna currentpos = EDI - EBX  (EDI è indirizzo dopo l'occorrenza)
    movl %edi, %eax
    subl %ebx, %eax # currpos = address corrente - base
    movl %eax, currentpos

    # stampa messaggio di occorrenza trovata
    lea msg_found, %ebx
    call outline               # stampa "Trovata occorrenza di\r\n"
    movb currentitem, %al
    call outbyte               # stampa il byte cercato
    call newline

    lea msg_counter, %ebx
    call outline               # "Conteggio attuale:\r\n"
    movb currentcount, %al
    call outdecimal_byte
    call newline
    call newline

    jmp search_end

search_not_found:
    # non trovato: stampa riepilogo e termina scansione
    lea msg_term, %ebx # stampa "Scansione array terminata.\r\n"
    call outline
    lea msg_tot, %ebx # stampa "Totale:\r\n"
    call outline
    movb currentcount, %al
    call outdecimal_byte
    call newline
    call newline

    # reset stato ricerca
    xor %eax, %eax
    movl %eax, currentpos
    movb %al, currentitem

search_end:
    pop %edi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    ret
