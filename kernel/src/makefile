BUILD_DIR?=build/
ASM?=nasm

.PHONY: all clean

all: boot5

boot5: $(BUILD_DIR)/boot5.bin

$(BUILD_DIR)/boot5.bin:
	$(ASM) boot5.asm -f bin -o $(BUILD_DIR)/boot5.bin

clean:
	rm -f $(BUILD_DIR)/boot5.bin