.code16
.section .text
.global _start

_start:
    mov ax, 0x07C0
    mov %ds, ax
    mov es, ax

    mov 0x0003, ax
    int 0x10

    mov ax, 0xB800
    mov es, es

    print_msg:
    xor si, si          ; Set string index to 0
    xor di, di          ; Set video memory index to 0

    .loop:
        mov al, [msg + si]  ; Load character
        cmp al, 0           ; Check if it's the end of string
        je .done
        
        mov [es:di], al     ; Write character byte
        mov byte [es:di+1], 0x07 ; Write color attribute byte
        
        inc si              ; Next character
        add di, 2           ; Next screen slot (char + color)
        jmp .loop

        /* Строка 2: приглашение "<>& " (строка 2 начинается с 160-го байта) */
        /* Line 2: invitation “<>& ” (line 2 starts at byte 160) */
        movb $'<', %es:160
        movb $0x07, %es:161
        movb $'>', %es:162
        movb $0x07, %es:163
        movb $'&', %es:164
        movb $0x07, %es:165
        movb $' ', %es:166
        movb $0x07, %es:167

        /* Позиция для ввода (следующий символ после "<>& ") */
        /* Input position (the character following “<>& ”) */
        mov $168, %bp

        /* Включаем аппаратный курсор */
        /* Enable the hardware cursor */
        mov $0x0100, %cx
        mov $0x0203, %dx
        mov $0x01, %ah
        int $0x10

    read_loop:
        mov $0x00, %ah
        int $0x16

        cmp $0x0D, %al
        je newline

        /* Выводим символ на текущей позиции ввода */
        /* Print the character at the current input position */
        mov %al, %es:(%bp)
        movb $0x07, %es:1(%bp)
        add $2, %bp
        jmp read_loop

    newline:
        /* Переход на новую строку */
        /* New line */
        mov $160, %ax
        add %bp, %ax
        and $0xFFE0, %ax
        add $160, %ax
        mov %ax, %bp



    /* Выводим приглашение на новой строке */
    /* Display the invitation on a new line */
    movb $'<', %es:(%bp)
    movb $0x07, %es:1(%bp)
    movb $'>', %es:2(%bp)
    movb $0x07, %es:3(%bp)
    movb $'&', %es:4(%bp)
    movb $0x07, %es:5(%bp)
    movb $' ', %es:6(%bp)
    movb $0x07, %es:7(%bp)
    add $8, %bp
    jmp read_loop

    cli
    hlt

    . = 510
    .word 0xAA55

section .data
    bootmsg db "core/713 installer", 0
    ; I would recommend not to put this in the first stage but save for later as it takes up valuable boot loader space
