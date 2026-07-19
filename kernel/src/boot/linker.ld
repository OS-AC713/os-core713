ENTRY(_start)
OUTPUT_FORMAT("binary")

SECTIONS
{
    /* Stage 2 is loaded at 0x0000:0x0500 by boot5.asm */
    . = 0x500;

    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss)  }
}