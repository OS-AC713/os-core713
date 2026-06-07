ASM=nasm
CC=gcc
LD=ld
OBJCOPY=objcopy

SRC_DIR=kernel/src
BUILD_DIR=build/

.PHONY: all floppy_image bootloader clean always

all: floppy_image bootloader

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/boot5.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	# copy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/stage2.bin "::stage2.bin"

#
# Bootloader
#
bootloader: boot5

boot5: $(BUILD_DIR)/boot5.bin

$(BUILD_DIR)/boot5.bin: always
	$(MAKE) -C $(SRC_DIR) BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/boot5 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*