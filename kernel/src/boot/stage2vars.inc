; Stack Initilisation size (16 bit)
spStackInitial equ 0x7C00

; VBE
; ax = Width
; bx = Height
; cl = bpp

vbeWidth    equ 1920
vbeHeight   equ 1080
vbeBpp      equ 32

; KDB stuff
KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64
KbdControllerDisableKeyboard        equ 0xAD
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1

; VBE screen buffer
ScreenBuffer                        equ 0xB8000