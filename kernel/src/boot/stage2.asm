%include "stage2vars.inc"
bits 16
section .text

global _start

_start:

    cli                                                     ; Clear interupts to avoid mistake input
    mov [g_BootDrive], dl                                   ; Save Bootdrive

    xor ax, ax

    mov ds, ax
    mov es, ax
    mov ss, ax

    
    mov sp, spStackInitial                                  ; Defined in stage2vars.inc
    mov bp, sp

    ; VBE Graphics Setup

    ; ax = Width
    ; bx = Height
    ; cl = bpp
    mov ax, vbeWidth
    mov bx, vbeHeight
    mov cl, vbeBpp
    call vbeSetMode

    ; Protected (32 bit) mode setup

    ; Enable A20
    call EnableA20

    ; Load GDT (Global Descriptor Table)
    call LoadGDT

    ; Set the protection flag in CR0
    mov eax, cr0        ; Contol Register 0 for protected mode
    or al, 1            ; or sets destination (al) 1 bitwise
    mov cr0, eax

    ; Far Jump into 32 bit!!
    jmp dword 08h:.pmode







.pmode:
    [bits 32]                                               ; Ensure 32 bit compilation
    ; We are in 32 bits

    ; Setup segment registers
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    

    ; VBE heheheheheh

    ; Draw Pixel Structure:

    ; mov edi, [vbe_screen.physical_buffer]     ; Get framebuffer base adress
    ; movzx eax, word [vbe_screen.pitch]        ; eax = bytes per scanline
    ; mov ebx, 50                               ; y = 50
    ; mul ebx                                   ; eax = y * pitch
    ; mov ebx, 50                               ; x = 50
    ; shl ebx, 2                                ; ebx = x * 4 (cause of 32 bpp)
    ; add eax, ebx                              ; eax = y * pitch + x * 4
    ; add edi, eax                              ; edi = framebuffer + offset
    ; mov dword [edi], 0x00FF0000               ; THis draws the pixel, hex value is colour

    mov edi, [vbe_screen.physical_buffer]   ; Get framebuffer base address
    movzx eax, word [vbe_screen.pitch]      ; eax = bytes per scanline (pitch)
    mov ebx, 50                             ; y = 50
    mul ebx                                 ; eax = y * pitch
    mov ebx, 50                             ; x = 50
    shl ebx, 2                              ; ebx = x * 4 (for 32 bpp)
    add eax, ebx                            ; eax = y * pitch + x * 4
    add edi, eax                            ; edi = framebuffer + offset
    mov dword [edi], 0x00FF0000             ; Draw a red pixel (0x00RRGGBB)

    





















; A20 GATE
EnableA20:
    [bits 16]
    ; disable keyboard
    call A20WaitInput
    mov al, KbdControllerDisableKeyboard
    out KbdControllerCommandPort, al

    ; read control output port
    call A20WaitInput
    mov al, KbdControllerReadCtrlOutputPort
    out KbdControllerCommandPort, al

    call A20WaitOutput
    in al, KbdControllerDataPort
    push eax

    ; write control output port
    call A20WaitInput
    mov al, KbdControllerWriteCtrlOutputPort
    out KbdControllerCommandPort, al
    
    call A20WaitInput
    pop eax
    or al, 2                                    ; bit 2 = A20 bit
    out KbdControllerDataPort, al

    ; enable keyboard
    call A20WaitInput
    mov al, KbdControllerEnableKeyboard
    out KbdControllerCommandPort, al

    call A20WaitInput
    ret


A20WaitInput:
    [bits 16]
    ; wait until status bit 2 (input buffer) is 0
    ; by reading from command port, we read status byte
    in al, KbdControllerCommandPort
    test al, 2
    jnz A20WaitInput
    ret

A20WaitOutput:
    [bits 16]
    ; wait until status bit 1 (output buffer) is 1 so it can be read
    in al, KbdControllerCommandPort
    test al, 1
    jz A20WaitOutput
    ret


LoadGDT:
    [bits 16]
    lgdt [g_GDTDesc]
    ret








; GDT setup (32)
g_GDT:      ; NULL descriptor
            dq 0

            ; 32-bit code segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10011010b                ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

            ; 32-bit data segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10010010b                ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

            ; 16-bit code segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10011010b                ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 00001111b                ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

            ; 16-bit data segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10010010b                ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 00001111b                ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

g_GDTDesc:  dw g_GDTDesc - g_GDT - 1    ; limit = size of GDT
            dd g_GDT                    ; address of GDT

g_BootDrive: db 0





; Vbe Stuff :P

; vbeSetMode:
; 1 - Sets VESA mode
; In: AX - Width
; In: BX - Height
; In: CL - Bit / Pixel
; Out: FLAGS - Carry clear on sucsess, set on failure
; Out: vbeScreen structure

vbeSetMode:
    [bits 16]

    mov [.width],   ax
    mov [.height],  bx
    mov [.bpp],     cl

    sti             ; Some bioses require interuppts for VBE calls

    push es         ; some bios destroy es
    mov ax, ds
    mov es, ax      ; ES needs to point to data segment for the bios call
    mov ax, 0x4F00  ; AX becomes the value to get VBE BIOS INFO

    int 0x10        ; Call Interuppt

    pop es
    cli

    ; Comparing section - if bios does not support vbe, give error
    cmp ax, 0x4F
    jne .error

    ; Get pointer to video mode lsit
    mov ax, [vbe_info_block.video_modes + 2]    ; Segment
    mov es, ax                                  ; Moving ES to have [vbe_info_block.video_modes + 2]
    mov si, [vbe_info_block.video_modes]        ; Offset

.findMode:
    mov dx, [es:si]     ; Doing the offset thingy
    ;add si, 2
    cmp dx, 0xFFFF      ; Comparing dx to highest value in 16 bit, essentially asking : End of list?
    je .error

    push es
    push si
    push dx

    mov ax, ds
    mov es, ax      ; ES must poimt to the data segment for bios call
    mov ax, 0x4F01  ; Get VBE info
    mov cx, dx      ; Mode number to query
    mov di, mode_info_block

    int 0x10

    pop es
    pop si
    pop es

    ; Make sure if call fails we try next mode
    cmp ax, 0x4F
    jne .nextMode   ; (loop)

    ; Check attributes are what we want / have configured 
    ; We do this by comparing our mem labels with the mode info block, if it is not what we wand, we move to .nextMode to try again

    ; Compare Width
    mov ax, [.width]
    cmp ax, [mode_info_block.width]
    jne .nextMode

    ; Compare Height
    mov ax, [.height]
    cmp ax, [mode_info_block.height]
    jne .nextMode

    ; Compare BPP
    mov al, [.bpp]
    cmp al, [mode_info_block.bpp]
    jne .nextMode

    ; Once we find the suitable mode, we populate the vbe_screen structure

    ; Structured like:
    ; mov (reg), [info_block.value]
    ; mov [vbe_screen.value], (reg)

    mov ax, [mode_info_block.width]
    mov [vbe_screen.width], ax

    mov ax, [mode_info_block.height]
    mov [vbe_screen.height], ax

    mov eax, [mode_info_block.framebuffer]
    mov [vbe_screen.physical_buffer], eax

    mov ax, [mode_info_block.pitch]
    mov [vbe_screen.pitch], ax

    mov al, [mode_info_block.bpp]
    mov [vbe_screen.bpp], al

    ; Set da mode :3
    mov ax, 0x4F02
    mov bx, dx
    or bx, 0x4000       ; Bit 14 tells BIOS to map flat 32bit framebuffer
    int 0x10

    cmp ax, 0x4F
    jne .error

    clc     ; Sucsess (clear carry)
    ret























.nextMode:
    add si, 2
    jmp .findMode

























.error:
    stc     ; Fail
    jmp $


; Local Vars for vbeSetMode
.width  dw 0
.height dw 0
.bpp    db 0









;
;   BSS
;
section .bss 

; Vbe info block
vbe_info_block:
    .signature       resb 4
    .version         resw 1
    .oem_string_ptr  resd 1
    .capabilities    resd 1
    .video_modes     resd 1
    .total_memory    resw 1
    .oem_sw_rev      resw 1
    .oem_vendor_name resd 1
    .oem_prod_name   resd 1
    .oem_prod_rev    resd 1
    .reserved        resb 222
    .oem_data        resb 256

; VBE Mode Info Block
mode_info_block:
    .attributes      resw 1
    .window_a        resb 2
    .granularity     resw 1
    .window_size     resw 1
    .segment_a       resw 1
    .segment_b       resw 1
    .win_func_ptr    resd 1
    .pitch           resw 1
    .width           resw 1
    .height          resw 1
    .w_char          resb 1
    .y_char          resb 1
    .planes          resb 1
    .bpp             resb 1
    .banks           resb 1
    .memory_model    resb 1
    .bank_size       resb 1
    .image_pages     resb 1
    .reserved1       resb 1
    .red_mask        resb 1
    .red_position    resb 1
    .green_mask      resb 1
    .green_position  resb 1
    .blue_mask       resb 1
    .blue_position   resb 1
    .rsv_mask        resb 1
    .rsv_position    resb 1
    .direct_color    resb 1
    .framebuffer     resd 1
    .off_screen_mem  resd 1
    .off_screen_size resw 1
    .reserved2       resb 206









;
;   DATA SECTION
;
section .data 

; This structure will hold the graphics mode info for the kernel
vbe_screen:
    .width            dw 0
    .height           dw 0
    .pitch            dw 0
    .bpp              db 0
    .physical_buffer  dd 0