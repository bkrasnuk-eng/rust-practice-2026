; ==========================================
; Signed vs Unsigned comparison (i386 NASM)
; Debian Linux, int 0x80 only
; ==========================================

SECTION .data
    prompt1 db "Enter a: ", 0
    prompt2 db "Enter b: ", 0

    out_signed db "SIGNED: ", 0
    out_unsigned db "UNSIGNED: ", 0

    str_lt db "a < b", 10, 0
    str_eq db "a = b", 10, 0
    str_gt db "a > b", 10, 0

    out_max_signed db "max_signed: ", 0
    out_max_unsigned db "max_unsigned: ", 0

SECTION .bss
    buf resb 32
    a   resd 1
    b   resd 1
    tmp resd 1

SECTION .text
    global _start

; ==========================================
; I/O helpers
; ==========================================

print:
    ; eax = address
    push eax
    call strlen
    mov edx, eax
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

strlen:
    ; eax = string
    push ecx
    mov ecx, eax
.len_loop:
    cmp byte [ecx], 0
    je .done
    inc ecx
    jmp .len_loop
.done:
    sub ecx, eax
    mov eax, ecx
    pop ecx
    ret

read_line:
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 32
    int 0x80
    ret

; ==========================================
; parse (ASCII -> int)
; ==========================================

atoi:
    ; input: buf
    ; output: eax
    mov esi, buf
    xor eax, eax
    xor ebx, ebx
    mov bl, 0          ; sign = 0

    cmp byte [esi], '-'
    jne .parse
    mov bl, 1
    inc esi

.parse:
    xor eax, eax
.loop:
    movzx edx, byte [esi]
    cmp edx, 10
    je .done
    cmp edx, 0
    je .done

    sub edx, '0'
    imul eax, eax, 10
    add eax, edx

    inc esi
    jmp .loop

.done:
    cmp bl, 0
    je .ret
    neg eax
.ret:
    ret

; ==========================================
; print number
; ==========================================

print_int:
    ; eax = number
    mov edi, buf
    add edi, 31
    mov byte [edi], 0
    dec edi

    mov ecx, 0
    cmp eax, 0
    jge .convert
    neg eax
    mov ecx, 1

.convert:
    mov ebx, 10
.conv_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .conv_loop

    cmp ecx, 0
    je .done
    mov byte [edi], '-'
    dec edi

.done:
    inc edi
    mov eax, edi
    call print
    ret

; ==========================================
; logic: comparisons
; ==========================================

cmp_signed:
    ; eax=a, ebx=b
    cmp eax, ebx
    jl .lt
    jg .gt
    mov eax, str_eq
    ret
.lt:
    mov eax, str_lt
    ret
.gt:
    mov eax, str_gt
    ret

cmp_unsigned:
    ; eax=a, ebx=b
    cmp eax, ebx
    jb .lt
    ja .gt
    mov eax, str_eq
    ret
.lt:
    mov eax, str_lt
    ret
.gt:
    mov eax, str_gt
    ret

max_signed:
    cmp eax, ebx
    jge .ret_a
    mov eax, ebx
.ret_a:
    ret

max_unsigned:
    cmp eax, ebx
    jae .ret_a
    mov eax, ebx
.ret_a:
    ret

; ==========================================
; main
; ==========================================

_start:

    ; ===== I/O =====
    mov eax, prompt1
    call print
    call read_line
    call atoi
    mov [a], eax

    mov eax, prompt2
    call print
    call read_line
    call atoi
    mov [b], eax

    ; ===== SIGNED =====
    mov eax, out_signed
    call print

    mov eax, [a]
    mov ebx, [b]
    call cmp_signed
    call print

    ; ===== UNSIGNED =====
    mov eax, out_unsigned
    call print

    mov eax, [a]
    mov ebx, [b]
    call cmp_unsigned
    call print

    ; ===== max_signed =====
    mov eax, out_max_signed
    call print

    mov eax, [a]
    mov ebx, [b]
    call max_signed
    call print_int

    mov eax, 10
    push eax
    mov eax, esp
    call print
    add esp, 4

    ; ===== max_unsigned =====
    mov eax, out_max_unsigned
    call print

    mov eax, [a]
    mov ebx, [b]
    call max_unsigned
    call print_int

    mov eax, 10
    push eax
    mov eax, esp
    call print
    add esp, 4

    ; ===== exit =====
    mov eax, 1
    xor ebx, ebx
    int 0x80
