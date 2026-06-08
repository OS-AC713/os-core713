; org 0x7C00                      ; Tell NASM where the code is loaded
bits 16
section .text

global _start

_start:

    mov [g_BootDrive], dl


    ; Set up registers and stack
    xor ax, ax                  ; Clear AX
    mov ds, ax
    mov ss, ax
    mov sp, 0xFFFF              ; Proper 16-bit stack pointer boundary
    mov bp, sp

    ; Print the boot message using BIOS
    mov si, bootmsg
    call puts

    ; Set up ES to point to video memory segment (0xB800)
    ; Direct memory writes like [es:160] need this segment!
    mov ax, 0xB800
    mov es, ax

    ; --- Line 2: Prompt starts at byte 160 ---
    mov byte [es:160], ' '
    mov byte [es:161], 0x07
    mov byte [es:162], ' '
    mov byte [es:163], 0x07
    mov byte [es:164], '&'
    mov byte [es:165], 0x07
    mov byte [es:166], ' '
    mov byte [es:167], 0x07

    ; Input pointer setup (Start typing at byte 168)
    mov di, 168

    ; Enable hardware cursor
    mov cx, 0x0100
    mov dx, 0x0203
    mov ah, 0x01
    int 0x10

read_loop:
    ; Read keystroke
    mov ah, 0x00
    int 0x16
    
    ; Check for Enter key (carriage return)
    cmp al, 0x0D
    je newline

    ; Print typed character to video memory
    mov [es:di], al
    mov byte [es:di+1], 0x07
    add di, 2
    jmp read_loop

newline:
    ; Calculate start of the next line
    mov ax, di
    add ax, 160
    and ax, 0xFFE0              ; Align to start of 160-byte row boundary
    mov di, ax

    ; Print prompt on the new line
    mov byte [es:di], ' '
    mov byte [es:di+1], 0x07
    mov byte [es:di+2], ' '
    mov byte [es:di+3], 0x07
    mov byte [es:di+4], '&'
    mov byte [es:di+5], 0x07
    mov byte [es:di+6], ' '
    mov byte [es:di+7], 0x07
    add di, 8
    jmp read_loop

    ; Fallback halt
    cli
    hlt

puts:
    pusha               ; Save all registers cleanly

.loop:
    lodsb               ; Loads next character from [ds:si] into AL
    or al, al           ; Check if next character is null terminator (0)
    jz .done

    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0           ; Page number 0
    int 0x10

    jmp .loop

.done:
    popa                ; Restore all registers cleanly
    ret

section .data
    bootmsg db "core/713 installer", 0x0D, 0x0A, 0
