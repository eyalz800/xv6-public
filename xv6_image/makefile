.PHONY: all mkdirs clean

mode ?= debug

CONFIGURATION_NAME := $(mode)
TARGET_ABI := x86
KERNEL_LIBRARY := ../kernel/out/$(CONFIGURATION_NAME)/$(TARGET_ABI)/libkernel.lib 
USER_MODE_FILES := $(shell find ../user/out/$(CONFIGURATION_NAME)/$(TARGET_ABI) -type f -not -name "*.a" 2> /dev/null)
INCLUDES := \
	../kernel/inc \
	../user/inc

CC = gcc
AS = gas
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
CFLAGS = -fno-pic -nostdlib -static -fno-builtin -fno-strict-aliasing -O2 -Wall -ggdb -m32 -Werror -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
ASFLAGS = -m32 -gdwarf-2 -Wa,-divide
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)

all: out/xv6.img

mkdirs:
	@mkdir -p out; \
	mkdir -p obj

clean: 
	@rm -rf out; \
	rm -rf obj
	
obj/initcode: src/initcode.S | mkdirs
	@$(CC) $(CFLAGS) -nostdinc $(patsubst %, -I%, $(INCLUDES)) -c src/initcode.S -o obj/initcode.o; \
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o obj/initcode.out obj/initcode.o; \
	$(OBJCOPY) -S -O binary obj/initcode.out obj/initcode; \
	$(OBJDUMP) -S obj/initcode.o > obj/initcode.asm
	
obj/entryother: src/entryother.S | mkdirs
	@$(CC) $(CFLAGS) -fno-pic -nostdinc $(patsubst %, -I%, $(INCLUDES)) -c src/entryother.S -o obj/entryother.o; \
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7000 -o obj/bootblockother.o obj/entryother.o; \
	$(OBJCOPY) -S -O binary -j .text obj/bootblockother.o obj/entryother; \
	$(OBJDUMP) -S obj/bootblockother.o > obj/entryother.asm
	
obj/bootblock: src/bootasm.S src/bootmain.c | mkdirs
	@$(CC) $(CFLAGS) -fno-pic -O -nostdinc $(patsubst %, -I%, $(INCLUDES)) -c src/bootmain.c -o obj/bootmain.o; \
	$(CC) $(CFLAGS) -fno-pic -nostdinc $(patsubst %, -I%, $(INCLUDES)) -c src/bootasm.S -o obj/bootasm.o; \
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o obj/bootblock.o obj/bootasm.o obj/bootmain.o; \
	$(OBJDUMP) -S obj/bootblock.o > obj/bootblock.asm; \
	$(OBJCOPY) -S -O binary -j .text obj/bootblock.o obj/bootblock; \
	./src/sign.pl obj/bootblock

obj/kernel: obj/initcode obj/entryother src/kernel.ld $(KERNEL_LIBRARY) | mkdirs
	@$(CC) -c $(CFLAGS) src/kernel_resources.S -o obj/kernel_resources.o; \
	$(LD) $(LDFLAGS) -T src/kernel.ld -o obj/kernel obj/kernel_resources.o $(KERNEL_LIBRARY); \
	$(OBJDUMP) -S obj/kernel > obj/kernel.asm; \
	$(OBJDUMP) -t obj/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > obj/kernel.sym

obj/mkfs: src/mkfs.c | mkdirs
	@gcc -O2 $(patsubst %, -idirafter%, $(INCLUDES)) -Werror -Wall -o obj/mkfs src/mkfs.c

out/fs.img: obj/mkfs $(USER_MODE_FILES)
	@./obj/mkfs out/fs.img $(USER_MODE_FILES)
	
out/xv6.img: obj/bootblock obj/kernel out/fs.img
	dd if=/dev/zero of=out/xv6.img count=10000
	dd if=obj/bootblock of=out/xv6.img conv=notrunc
	dd if=obj/kernel of=out/xv6.img seek=1 conv=notrunc
