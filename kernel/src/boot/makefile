# Directories
BUILD_DIR ?= ../../../build

# Tools
ASM?=nasm
CC?=gcc
LD?=ld

.PHONY: all clean

all: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/boot5.bin $(BUILD_DIR)/stage2.bin
	@mkdir -p $(BUILD_DIR)
	# 1. Create a blank 1.44MB floppy image
	dd if=/dev/zero of=$@ bs=512 count=2880
	# 2. Format as FAT12
	mkfs.fat -F 12 -n "CORE713" $@
	# 3. Write the first stage bootloader to the first sector
	dd if=$(BUILD_DIR)/boot5.bin of=$@ conv=notrunc
	# 4. Copy the second stage into the filesystem
	mcopy -i $@ $(BUILD_DIR)/stage2.bin ::STAGE2.BIN

$(BUILD_DIR)/boot5.bin: boot5.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) boot5.asm -f bin -o $(BUILD_DIR)/boot5.bin

$(BUILD_DIR)/stage2.bin: stage2.asm linker.ld
	@mkdir -p $(BUILD_DIR)
	# Assemble using GCC (handles the .intel_syntax directive)
	$(ASM) stage2.asm -f elf -o $(BUILD_DIR)/stage2.o
	# Link into a flat binary at 0x0500
	$(LD) -m elf_i386 -T linker.ld -o $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/stage2.o

clean:
	rm -rf $(BUILD_DIR)