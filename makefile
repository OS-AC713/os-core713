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

$(BUILD_DIR)/main_floppy.img: always
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Bootloader
#
bootloader: boot5

boot5: $(BUILD_DIR)/boot5.bin

$(BUILD_DIR)/boot5.bin: always
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*