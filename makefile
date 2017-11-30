.PHONY: all clean run debug qemu qemu-nox qemu-gdb qemu-nox-gdb

mode ?= debug
cpus ?= 2

CONFIGURATION_NAME := $(mode)
TARGET_ABI := x86
CPU_COUNT := $(cpus)

QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)

QEMUOPTS = -drive \
	file=./xv6_image/out/fs.img,index=1,media=disk,format=raw \
	-drive file=./xv6_image/out/xv6.img,index=0,media=disk,format=raw \
	-smp $(CPU_COUNT) \
	-m 512
	
all:
	@$(MAKE) -s -C ./kernel; \
	$(MAKE) -s -C ./user; \
	$(MAKE) -s -C ./xv6_image

clean: 
	@rm -f gdb/command; \
	$(MAKE) -s -C ./kernel clean; \
	$(MAKE) -s -C ./user clean; \
	$(MAKE) -s -C ./xv6_image clean

# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
CPUS := 2
endif

ifndef QEMU
QEMU = $(shell if which qemu > /dev/null; \
	then echo qemu; exit; \
	elif which qemu-system-i386 > /dev/null; \
	then echo qemu-system-i386; exit; \
	elif which qemu-system-x86_64 > /dev/null; \
	then echo qemu-system-x86_64; exit; \
	else \
	qemu=/Applications/Q.app/Contents/MacOS/i386-softmmu.app/Contents/MacOS/i386-softmmu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "*** or have you tried setting the QEMU variable in Makefile?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

run:
	@$(QEMU) -nographic $(QEMUOPTS)

debug:
	@sed "s/localhost:1234/localhost:$(GDBPORT)/" < gdb/command.template > gdb/command; \
	echo "Waiting for debugger on localhost:$(GDBPORT)..." 1>&2 ; \
	$(QEMU) -nographic $(QEMUOPTS) -S $(QEMUGDB)

qemu: all
	@$(QEMU) -serial mon:stdio $(QEMUOPTS)

qemu-nox: all
	@$(QEMU) -nographic $(QEMUOPTS)

qemu-gdb: all
	@sed "s/localhost:1234/localhost:$(GDBPORT)/" < gdb/command.template > gdb/command; \
	echo "Waiting for debugger on localhost:$(GDBPORT)..." 1>&2 ; \
	$(QEMU) -serial mon:stdio $(QEMUOPTS) -S $(QEMUGDB)

qemu-nox-gdb: all
	@sed "s/localhost:1234/localhost:$(GDBPORT)/" < gdb/command.template > gdb/command; \
	echo "Waiting for debugger on localhost:$(GDBPORT)..." 1>&2 ; \
	$(QEMU) -nographic $(QEMUOPTS) -S $(QEMUGDB)
