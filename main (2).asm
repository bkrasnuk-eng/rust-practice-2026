; practice5.asm
; Мова: i386 (32-bit)
; Вхід: одне додатне число x (1..2000000000) з консолі
; Вихід: два рядки — sumDigits(x) і len(x)
; Використовує unsigned div, цикл while, підпрограми atoi/itoa

global _start

section .bss
    input_buffer  resb 16     ; буфер для введення
    output_buffer resb 16     ; буфер для виведення

section .data
    newline db 10

section .text
_start:
    ; =============================================
    ; I/O: читання рядка з консолі
    ; =============================================
    mov eax, 3                ; sys_read
    mov ebx, 0                ; stdin
    mov ecx, input_buffer
    mov edx, 15
    int 0x80

    ; =============================================
    ; parse: конвертація рядка в число (atoi) → EAX
    ; =============================================
    call atoi
    ; тепер EAX = x (1..2000000000)

    mov ebx, eax              ; зберігаємо x в EBX
    xor ecx, ecx              ; sumDigits = 0
    xor edx, edx              ; len = 0

    ; =============================================
    ; loops + math: обчислення sumDigits і len за допомогою div
    ; =============================================
compute_loop:
    cmp ebx, 0
    jle compute_done          ; while x > 0

    ; math: unsigned ділення на 10
    mov eax, ebx
    mov edi, 10
    xor edx, edx              ; обов'язково обнуляємо EDX перед div!
    div edi                   ; EAX = x / 10, EDX = x % 10

    ; math: додаємо цифру до суми
    add ecx, edx              ; sumDigits += remainder

    ; logic: збільшуємо кількість цифр
    inc edx                   ; len += 1  (EDX вже містить 1..9 або 0)

    mov ebx, eax              ; x = x / 10
    jmp compute_loop

compute_done:
    ; тепер ECX = sumDigits, EDX = len (з останнього increment)

    ; =============================================
    ; I/O + itoa: вивід sumDigits
    ; =============================================
    mov eax, ecx              ; передаємо sumDigits в EAX
    call itoa
    call print_output

    ; =============================================
    ; I/O + itoa: вивід len
    ; =============================================
    mov eax, edx              ; передаємо len в EAX
    call itoa
    call print_output

    ; =============================================
    ; I/O: завершення програми
    ; =============================================
    mov eax, 1                ; sys_exit
    xor ebx, ebx
    int 0x80

; =============================================
; parse: підпрограма atoi (string → int)
; =============================================
atoi:
    push ebx
    push esi
    mov esi, input_buffer
    xor eax, eax              ; результат = 0
atoi_loop:
    mov bl, [esi]
    cmp bl, 10                ; '\n'
    je atoi_done
    cmp bl, 0
    je atoi_done
    cmp bl, '0'
    jb atoi_done
    cmp bl, '9'
    ja atoi_done

    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp atoi_loop
atoi_done:
    pop esi
    pop ebx
    ret

; =============================================
; memory + math + loops: підпрограма itoa (int → string в output_buffer)
; =============================================
itoa:
    push edi
    mov edi, output_buffer
    add edi, 14               ; починаємо з кінця
    mov byte [edi], 10        ; '\n'
    dec edi

    cmp eax, 0
    jne itoa_loop

    mov byte [edi], '0'
    dec edi
    jmp itoa_finish

itoa_loop:
    mov ebx, 10
    xor edx, edx
    div ebx                   ; EAX /= 10, EDX = цифра

    add dl, '0'
    mov [edi], dl
    dec edi

    test eax, eax
    jnz itoa_loop

itoa_finish:
    inc edi                   ; EDI вказує на початок числа
    mov [output_buffer + 15], edi  ; зберігаємо початок для print (тимчасово)
    pop edi
    ret

; =============================================
; I/O: вивід рядка з output_buffer
; =============================================
print_output:
    push ecx
    push edx

    mov ecx, [output_buffer + 15]   ; адреса початку рядка
    mov edx, output_buffer
    add edx, 15
    sub edx, ecx                    ; довжина

    mov eax, 4                ; sys_write
    mov ebx, 1                ; stdout
    int 0x80

    pop edx
    pop ecx
    ret