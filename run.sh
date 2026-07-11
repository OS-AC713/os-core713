qemu-system-i386 -hda build/main_floppy.img -d int,cpu -D qemu.log

# Debug Options: -d int,cpu_reset -D qemu_debug.log for logging to qemu_debug.log
# Using 32bit qemu simulation a hard disk with kernel.bin engraved