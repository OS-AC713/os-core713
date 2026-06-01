.code16
.section .text
.globl _start

_start:
    mov $0x07C0, %ax
    mov %ax, %ds
    mov %ax, %es

    mov $0x0003, %ax
    int $0x10

    mov $0xB800, %ax
    mov %ax, %es

    /* Строка 0: "core/713 installer" */
    movb $'c', %es:0
    movb $0x07, %es:1
    movb $'o', %es:2
    movb $0x07, %es:3
    movb $'r', %es:4
    movb $0x07, %es:5
    movb $'e', %es:6
    movb $0x07, %es:7
    movb $'/', %es:8
    movb $0x07, %es:9
    movb $'7', %es:10
    movb $0x07, %es:11
    movb $'1', %es:12
    movb $0x07, %es:13
    movb $'3', %es:14
    movb $0x07, %es:15
    movb $' ', %es:16
    movb $0x07, %es:17
    movb $'i', %es:18
    movb $0x07, %es:19
    movb $'n', %es:20
    movb $0x07, %es:21
    movb $'s', %es:22
    movb $0x07, %es:23
    movb $'t', %es:24
    movb $0x07, %es:25
    movb $'a', %es:26
    movb $0x07, %es:27
    movb $'l', %es:28
    movb $0x07, %es:29
    movb $'l', %es:30
    movb $0x07, %es:31
    movb $'e', %es:32
    movb $0x07, %es:33
    movb $'r', %es:34
    movb $0x07, %es:35

    /* Строка 2: приглашение "<>& " (строка 2 начинается с 160-го байта) */
    movb $'<', %es:160
    movb $0x07, %es:161
    movb $'>', %es:162
    movb $0x07, %es:163
    movb $'&', %es:164
    movb $0x07, %es:165
    movb $' ', %es:166
    movb $0x07, %es:167

    /* Позиция для ввода (следующий символ после "<>& ") */
    mov $168, %bp

    /* Включаем аппаратный курсор */
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
    mov %al, %es:(%bp)
    movb $0x07, %es:1(%bp)
    add $2, %bp
    jmp read_loop

newline:
    /* Переход на новую строку */
    mov $160, %ax
    add %bp, %ax
    and $0xFFE0, %ax
    add $160, %ax
    mov %ax, %bp

    /* Выводим приглашение на новой строке */
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
