; ==========================================
; Bit operations (i386 NASM)
; Debian Linux, int 0x80 only
; ==========================================

SECTION .data
    prompt db "Enter x: ",0

    out_bin db "Binary: ",0
    out_pop db 10,"Popcount: ",0
    out_mod db 10,"Modified: ",0

    space db " ",0
    nl db 10,0

SECTION .bss
    buf resb 64
    x resd 1

SECTION .text
    global _start

; ==========================================
; I/O
; ==========================================

print:
    push eax
    call strlen
    mov edx,eax
    pop ecx
    mov eax,4
    mov ebx,1
    int 0x80
    ret

strlen:
    push ecx
    mov ecx,eax
.l:
    cmp byte [ecx],0
    je .d
    inc ecx
    jmp .l
.d:
    sub ecx,eax
    mov eax,ecx
    pop ecx
    ret

read_line:
    mov eax,3
    mov ebx,0
    mov ecx,buf
    mov edx,64
    int 0x80
    ret

; ==========================================
; parse
; ==========================================

atoi:
    mov esi,buf
    xor eax,eax
    xor ebx,ebx

    cmp byte [esi],'-'
    jne .loop
    mov bl,1
    inc esi

.loop:
    movzx edx,byte [esi]
    cmp edx,10
    je .done
    cmp edx,0
    je .done

    sub edx,'0'
    imul eax,eax,10
    add eax,edx

    inc esi
    jmp .loop

.done:
    cmp bl,0
    je .ret
    neg eax
.ret:
    ret

; ==========================================
; print int
; ==========================================

print_int:
    mov edi,buf
    add edi,63
    mov byte [edi],0
    dec edi

    cmp eax,0
    jge .conv
    neg eax
    mov bl,1
    jmp .go
.conv:
    mov bl,0
.go:
    mov ecx,10
.loop:
    xor edx,edx
    div ecx
    add dl,'0'
    mov [edi],dl
    dec edi
    test eax,eax
    jnz .loop

    cmp bl,0
    je .done
    mov byte [edi],'-'
    dec edi

.done:
    inc edi
    mov eax,edi
    call print
    ret

; ==========================================
; main
; ==========================================

_start:

    ; ===== I/O =====
    mov eax,prompt
    call print
    call read_line
    call atoi
    mov [x],eax

    ; ===== binary print =====
    mov eax,out_bin
    call print

    mov eax,[x]
    mov ecx,32

.bin_loop:
    mov edx,eax
    and edx,0x80000000     ; старший біт

    cmp edx,0
    jne .bit1

    mov bl,'0'
    jmp .print_bit

.bit1:
    mov bl,'1'

.print_bit:
    push ebx
    mov eax,esp
    call print
    add esp,4

    shl eax,1

    ; групування по 4
    mov edx,ecx
    dec edx
    and edx,3
    cmp edx,0
    jne .skip_space

    mov eax,space
    call print

.skip_space:
    dec ecx
    jnz .bin_loop

    ; ===== popcount =====
    mov eax,out_pop
    call print

    mov eax,[x]
    xor ecx,ecx

.pop_loop:
    mov edx,eax
    and edx,1
    add ecx,edx
    shr eax,1
    cmp eax,0
    jne .pop_loop

    mov eax,ecx
    call print_int

    ; ===== bit operations =====
    ; set p=1, q=3, clear r=2

    mov eax,[x]

    ; set bit 1
    mov ebx,1
    shl ebx,1
    or eax,ebx

    ; set bit 3
    mov ebx,1
    shl ebx,3
    or eax,ebx

    ; clear bit 2
    mov ebx,1
    shl ebx,2
    not ebx
    and eax,ebx

    mov eax,out_mod
    call print

    call print_int

    mov eax,nl
    call print

    ; ===== exit =====
    mov eax,1
    xor ebx,ebx
    int 0x80