; project core/713, official links: https://github.com/OS-AC713/os-core713
; File author: OS-AC713
; Contributor: MrMagoo8888
; File name: boot5.asm
; License: GNU GPLv3.0 ( see the LICENSE file for details: https://github.com/OS-AC713/os-core713/blob/main/LICENSE )
;  WARNING: The file is provided WITHOUT ANY WARRANTY
;    TO SEE HOW TO CORRECTLY COMPILE A FILE, LOOK AT THE COMMIT ON THIS FILE!

bits 16
ORG 0x7C00



_start:
    mov ax, 0
    mov es, ax  ; I learned how to lay and how to work with ES

_st_rddisk:
    ; Here we begin to load the disk and start reading it
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    mov bx, 0x7E00
    int 0x13
    
    jmp disk_rd_succes

    jc _disk_error_panic
    
 

    
 


; err_bios_boot:
    ; This is just for later, then I plan to handle the error that the BIOS did not process our bootloader.
    ;mov ah, 0x0E
    
    ; mov al, 'B'
    ; int 0x10
    ; mov al, 'o'
    ; int 0x10
    ; mov al, 'o'
    ; int 0x10
    ; mov al, 't'
    ; int 0x10
    ; mov al, ' '
    ; int 0x10
    ; mov al, 'I'
    ; int 0x10
    ; mov al, 'n'
    ; int 0x10
    ; mov al, ' '
    ; int 0x10
    ; mov al, 'P'
    ; int 0x10
    ; mov al, 'a'
    ; int 0x10
    ; mov al, 'n'
    ; int 0x10
    ; mov al, 'i'
    ; int 0x10
    ; mov al, 'c'
    ; int 0x10
    ; mov al, '!'
    ; int 0x10
    ; mov al, 0x0D
    ; int 0x10
    ; mov al, 0x0A
    ; int 0x10
    ; xor al, al
    ; jmp 0x7C00_err

; 0x7C00_err:
   ; mov al, 'E'
   ; int 0x10
   ;  mov al, 'R'
   ; int 0x10
   ; mov al, ':'
   ; int 0x10
   ; mov al, ' '
   ; int 0x10
   ; mov al, 'U'
   ; int 0x10
   ; mov al, 'N'
   ; int 0x10
   ; mov al, 'B'
   ; int 0x10
   ; mov al, '_'
   ; int 0x10
   ; mov al, 'L'
   ; int 0x10
   ; mov al, 'D'
   ; int 0x10
   ; mov al, '_'
   ; int 0x10
   ; mov al, 'B'
   ; int 0x10
   ; mov al, 'I'
   ; int 0x10
   ; mov al, 'O'
   ; int 0x10
   ; mov al, 'S'
   ; int 0x10
   ; xor al, al

_disk_error_panic:
    mov ah, 0x0E
    
    mov al, 'B'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 't'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'I'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'P'
    int 0x10
    mov al, 'a'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, 'i'
    int 0x10
    mov al, 'c'
    int 0x10
    mov al, '!'
    int 0x10
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    mov al, 'E'
    int 0x10
    mov al, 'R'
    int 0x10
    mov al, ':'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'D'
    int 0x10
    mov al, 'S'
    int 0x10
    mov al, 'K'
    int 0x10
    mov al, '_'
    int 0x10
    mov al, 'U'
    int 0x10
    mov al, 'N'
    int 0x10
    mov al, 'B'
    int 0x10
    mov al, '_'
    int 0x10
    mov al, 'R'
    int 0x10
    mov al, 'E'
    int 0x10
    mov al, 'A'
    int 0x10
    mov al, 'D'
    int 0x10

disk_rd_succes:
    jmp 0x0000:0x7E00

hang:
    cli
    hlt
    jmp hang
    jmp $
    


times 510 - ($ - $$) db 0
dw 0xAA55
