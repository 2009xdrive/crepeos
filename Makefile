### crepeOS Makefile

.DEFAULT_GOAL := build

# These targets aren't triggered by a change of a file.
.PHONY: clean boot bootdebug

# This selects all programs and music files to be built.
PROGRAMS := $(patsubst %.asm,%.app,$(sort $(wildcard program/*.asm)))
SONGS := $(patsubst %.mus,%.mmf,$(sort $(wildcard live/*.mus)))
DROS := $(patsubst %.dro,%.drz,$(sort $(wildcard live/*.dro)))

# This selects all files to copy to the final image.
FILEDIRS := program/*.bas program/*.dat live/*.pcx live/*.rad live/*.asc source/sys/*.sys
FILES := $(PROGRAMS) $(SONGS) $(DROS) $(foreach dir,$(FILEDIRS),$(sort $(wildcard $(dir))))

# Default target: build the image and boot it.
build: image/crepeos.flp boot

# Optional target: force rebuild everything.
force: clean build

# Development target: build as usual, but use dosbox-debug instead of regular DOSBox.
dev: image/crepeos.flp bootdebug

# Bootloader target
system/osldr/osldr.bin: system/osldr/osldr.asm
	nasm -O2 -w+orphan-labels -f bin -o system/osldr/osldr.bin system/osldr/osldr.asm

# Kernel target
system/crepeos.sys: system/system.asm system/drivers/*.asm
	nasm -O2 -w+orphan-labels -f bin -I system/ -o system/crepeos.sys system/system.asm -l system/system.lst

# Assembles all programs.
# Note: % means file name prefix, $@ means output file and $< means source file.
program/%.app: program/%.asm program/%/*.asm program/crepeos.inc
	nasm -O2 -w+orphan-labels -f bin -I program/ -o $@ $< #-l $@.lst
	
program/%.app: program/%.asm program/crepeos.inc
	nasm -O2 -w+orphan-labels -f bin -I program/ -o $@ $< #-l $@.lst

# Assembles all songs.
live/%.mmf: live/%.mus live/notelist.txt
	nasm -O2 -w+orphan-labels -f bin -I live/ -o $@ $<

live/%.drz: live/%.dro
	misc/compress $< $@

# Builds the image.
image/crepeos.flp: system/osldr/osldr.bin system/crepeos.sys \
					$(PROGRAMS) $(SONGS) $(DROS)
	-rm image/*

	dd if=/dev/zero of=image/crepeos.flp bs=512 count=2880
	dd status=noxfer conv=notrunc if=system/osldr/osldr.bin of=image/crepeos.flp
	
	mcopy -i $@ system/crepeos.sys ::crepeos.sys
	mcopy -i $@ system/sys/font.sys ::font.sys
	mcopy -i $@ system/sys/bg.sys ::bg.sys
	$(foreach file,$(FILES),mcopy -i $@ $(file) ::$(notdir $(file));)

	mkisofs -quiet -V 'CREPEOS' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.flp image/

# Removes all of the built pieces.
clean:
	-rm image/*
	-rm program/*.app
	-rm program/*.lst
	-rm live/*.drz
	-rm live/*.mmf
	-rm system/*.sys
	-rm system/osldr/*.bin
	
# Boots the floppy.
boot:
	qemu-system-x86_64 -cdrom image/crepeos.iso

# Boots the floppy with dosbox-debug.
bootdebug:
	qemu-system-i386 -cdrom image/crepeos.iso

