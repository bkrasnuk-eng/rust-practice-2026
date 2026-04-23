; ==========================================
; Array build, min/max with indices (i386 NASM)
; Debian Linux, int 0x80 only
; ==========================================

SECTION .data
    prompt db "Enter n (5..50): ", 0

    out_array db "Array: ", 0
    out_min db 10, "Min: ", 0
    out_min_i db " index: ", 0
    out_max db 10, "Max: ", 0
    out_max_i db " index: ", 0

    space db " ", 0
    nl db 10, 0

SECTION .bss
    buf resb 32
    arr resd 50     ; memory: масив dd 50 dup(?)
    n   resd 1

SECTION .text
    global _start

; ==========================================
; I/O
; ==========================================

print:
    push eax
    call strlen
    mov edx, eax
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

strlen:
    push ecx
    mov ecx, eax
.l:
    cmp byte [ecx], 0
    je .d
    inc ecx
    jmp .l
.d:
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
; parse
; ==========================================

atoi:
    mov esi, buf
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
    ret

; ==========================================
; print int
; ==========================================

print_int:
    mov edi, buf
    add edi, 31
    mov byte [edi], 0
    dec edi

    cmp eax, 0
    jge .conv
    neg eax
    mov bl, 1
    jmp .go
.conv:
    mov bl, 0
.go:
    mov ecx, 10
.loop:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .loop

    cmp bl, 0
    je .done
    mov byte [edi], '-'
    dec edi

.done:
    inc edi
    mov eax, edi
    call print
    ret

; ==========================================
; main
; ==========================================

_start:

    ; ===== I/O =====
    mov eax, prompt
    call print

    call read_line
    call atoi
    mov [n], eax

    ; ===== logic (перевірка меж 5..50) =====
    cmp eax, 5
    jl exit
    cmp eax, 50
    jg exit

    ; ===== loops + math (заповнення масиву) =====
    ; формула: arr[i] = i*i - 3*i + 7
    xor ecx, ecx            ; i = 0
.fill_loop:
    mov eax, ecx
    imul eax, eax          ; i*i
    mov edx, ecx
    imul edx, 3            ; 3*i
    sub eax, edx
    add eax, 7

    mov [arr + ecx*4], eax ; memory: arr[i]

    inc ecx
    cmp ecx, [n]
    jl .fill_loop

    ; ===== пошук min/max =====
    mov eax, [arr]     ; min
    mov ebx, [arr]     ; max
    xor esi, esi       ; min index
    xor edi, edi       ; max index

    mov ecx, 1
.find_loop:
    mov edx, [arr + ecx*4]

    ; min
    cmp edx, eax
    jge .check_max
    mov eax, edx
    mov esi, ecx

.check_max:
    cmp edx, ebx
    jle .next
    mov ebx, edx
    mov edi, ecx

.next:
    inc ecx
    cmp ecx, [n]
    jl .find_loop

    ; ===== вивід масиву =====
    mov eax, out_array
    call print

    xor ecx, ecx
.print_loop:
    mov eax, [arr + ecx*4]
    call print_int

    mov eax, space
    call print

    inc ecx
    cmp ecx, [n]
    jl .print_loop

    ; ===== min =====
    mov eax, out_min
    call print

    mov eax, [arr + esi*4]
    call print_int

    mov eax, out_min_i
    call print

    mov eax, esi
    call print_int

    ; ===== max =====
    mov eax, out_max
    call print

    mov eax, [arr + edi*4]
    call print_int

    mov eax, out_max_i
    call print

    mov eax, edi
    call print_int

    mov eax, nl
    call print

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80