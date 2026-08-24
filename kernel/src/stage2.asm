; project core/713, official links: https://github.com/OS-AC713/os-core713
; File author: OS-AC713
; Contributor: MrMagoo8888
; File name: boot5.asm
; License: GNU GPLv3.0 ( see the LICENSE file for details: https://github.com/OS-AC713/os-core713/blob/main/LICENSE )
;  WARNING: The file is provided WITHOUT ANY WARRANTY
;    TO SEE HOW TO CORRECTLY COMPILE A FILE, LOOK AT THE COMMIT ON THIS FILE! https://github.com/OS-AC713/os-core713/commit/f1848cb9973b5f515e8efadefe9c8a49ac503e89

bits 16
org 0x7E00
mov ah, 0x0E
mov al, 'S'
int 0x10
mov al, '2'
int 0x10
hlt
jmp $
