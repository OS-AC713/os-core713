; project core/713, official links: https://github.com/OS-AC713/os-core713
; File author: OS-AC713
; Contributor: MrMagoo8888
; File name: boot5.asm
; License: GNU GPLv3.0 ( see the LICENSE file for details: https://github.com/OS-AC713/os-core713/blob/main/LICENSE )
;  WARNING: The file is provided WITHOUT ANY WARRANTY

bits 16
ORG 0x7C00

_start:

    mov ah, 0x0E
    xor bh, bh


    mov al, 'C'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, '/'
    int 0x10
    mov al, '7'
    int 0x10
    mov al, '1'
    int 0x10
    mov al, '3'
    int 0x10

 
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10


    mov al, '<'
    int 0x10
    mov al, '>'
    int 0x10
    mov al, '&'
    int 0x10
    mov al, ' '
    int 0x10

    xor cx, cx          

main_loop:

    mov ah, 0x01
    int 0x16
    jz main_loop

    mov ah, 0x00
    int 0x16            


    cmp al, 0x0D
    jne check_backspace
    call newline
    jmp main_loop

check_backspace:

    cmp al, 0x08
    jne print_char

    cmp cx, 0
    je main_loop        


    call delete_char
    dec cx              
    jmp main_loop

print_char:
   
    cmp al, 0x20        
    jb main_loop        

    mov ah, 0x0E
    xor bh, bh
    int 0x10
    inc cx              
    jmp main_loop


newline:
    mov ah, 0x0E
    xor bh, bh
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10


    mov al, '<'
    int 0x10
    mov al, '>'
    int 0x10
    mov al, '&'
    int 0x10
    mov al, ' '
    int 0x10

    xor cx, cx          
    ret

delete_char:
    mov ah, 0x0E
    xor bh, bh


    mov al, 0x08        
    int 0x10


    mov al, ' '
    int 0x10


    mov al, 0x08
    int 0x10
    ret


times 510 - ($ - $$) db 0
dw 0xAA55
