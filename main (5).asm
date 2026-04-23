; ==========================================
; Linear search + occurrences (i386 NASM)
; Debian Linux, int 0x80 only
; ==========================================

SECTION .data
    prompt_n db "Enter n (10..100): ",0
    prompt_arr db "Enter elements:",10,0
    prompt_t db "Enter target: ",0

    out_first db "First index: ",0
    out_count db 10,"Count: ",0
    out_list db 10,"Indexes: ",0

    space db " ",0
    nl db 10,0

SECTION .bss
    buf resb 32
    arr resd 100        ; memory: масив
    n resd 1
    target resd 1

    first resd 1
    count resd 1

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
    mov edx,32
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
    add edi,31
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
    mov eax,prompt_n
    call print
    call read_line
    call atoi
    mov [n],eax

    ; ===== logic (10..100) =====
    cmp eax,10
    jl exit
    cmp eax,100
    jg exit

    mov eax,prompt_arr
    call print

    ; ===== loops (ввід масиву) =====
    xor ecx,ecx
.input_loop:
    call read_line
    call atoi
    mov [arr + ecx*4],eax

    inc ecx
    cmp ecx,[n]
    jl .input_loop

    ; target
    mov eax,prompt_t
    call print
    call read_line
    call atoi
    mov [target],eax

    ; ===== logic (пошук) =====
    mov dword [first], -1
    mov dword [count], 0

    xor ecx,ecx
.search_loop:
    mov eax,[arr + ecx*4]
    cmp eax,[target]
    jne .next

    ; знайдено
    cmp dword [first], -1
    jne .skip_first
    mov [first],ecx

.skip_first:
    inc dword [count]

.next:
    inc ecx
    cmp ecx,[n]
    jl .search_loop

    ; ===== output =====
    mov eax,out_first
    call print
    mov eax,[first]
    call print_int

    mov eax,out_count
    call print
    mov eax,[count]
    call print_int

    mov eax,out_list
    call print

    ; список індексів
    cmp dword [count],0
    je .end_list

    xor ecx,ecx
.print_loop:
    mov eax,[arr + ecx*4]
    cmp eax,[target]
    jne .skip

    mov eax,ecx
    call print_int

    mov eax,space
    call print

.skip:
    inc ecx
    cmp ecx,[n]
    jl .print_loop

.end_list:
    mov eax,nl
    call print

exit:
    mov eax,1
    xor ebx,ebx
    int 0x80