### crepeOS Makefile

.DEFAULT_GOAL := build

# These targets aren't triggered by a change of a file.
.PHONY: clean boot bootdebug

# This selects all programs and music files to be built.
PROGRAMS := $(patsubst %.asm,%.app,$(sort $(wildcard live/program/*.asm)))
SONGS := $(patsubst %.mus,%.mmf,$(sort $(wildcard live/media1m/*.mus)))
DROS := $(patsubst %.dro,%.drz,$(sort $(wildcard live/media1m/*.dro)))

# This selects all files to copy to the final image.
FILEDIRS := live/program/*.bas live/program/*.dat live/media1i/*.pcx live/media1m/*.rad live/media1i/*.asc
FILES := $(PROGRAMS) $(SONGS) $(DROS) $(foreach dir,$(FILEDIRS),$(sort $(wildcard $(dir))))

# Default target: build the image and boot it.
build: image/crepeos.flp boot

# Optional target: force rebuild everything.
force: clean build

# Development target: build as usual, but use dosbox-debug instead of regular DOSBox.
dev: image/crepeos.flp bootdebug

# Bootloader target
live/system/osldr/osldr.bin: live/system/osldr/osldr.asm
	nasm -O2 -w+orphan-labels -f bin -o live/system/osldr/osldr.bin live/system/osldr/osldr.asm

# Kernel target
live/system/crepeos.sys: live/system/system.asm live/system/drivers/*.asm
	nasm -O2 -w+orphan-labels -f bin -I live/system/ -o live/system/crepeos.sys live/system/system.asm -l live/system/system.lst

# Assembles all programs.
# Note: % means file name prefix, $@ means output file and $< means source file.
live/program/%.app: live/program/%.asm live/program/%/*.asm live/program/crepeos.inc
	nasm -O2 -w+orphan-labels -f bin -I live/program/ -o $@ $< #-l $@.lst
	
live/program/%.app: live/program/%.asm live/program/crepeos.inc
	nasm -O2 -w+orphan-labels -f bin -I live/program/ -o $@ $< #-l $@.lst

# Assembles all songs.
live/media1m/%.mmf: live/media1m/%.mus live/media1m/notelist.txt
	nasm -O2 -w+orphan-labels -f bin -I live/media1m/ -o $@ $<

live/%.drz: live/%.dro
	misc/compress $< $@

# Builds the image.
image/crepeos.flp: live/system/osldr/osldr.bin live/system/crepeos.sys \
					$(PROGRAMS) $(SONGS) $(DROS)
	-rm image/*

	dd if=/dev/zero of=image/crepeos.flp bs=512 count=2880
	dd status=noxfer conv=notrunc if=live/system/osldr/osldr.bin of=image/crepeos.flp
	
	mcopy -i $@ live/system/crepeos.sys ::crepeos.sys
	mcopy -i $@ live/system/menu/font.sys ::font.sys
	mcopy -i $@ live/system/menu/bg.sys ::bg.sys
	$(foreach file,$(FILES),mcopy -i $@ $(file) ::$(notdir $(file));)

	mkisofs -quiet -V 'CREPEOS' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.flp image/

# Removes all of the built pieces.
clean:
	-rm image/*
	-rm live/program/*.app
	-rm live/program/*.lst
	-rm live/media1m/*.drz
	-rm live/media1m/*.mmf
	-rm live/system/*.sys
	-rm live/system/osldr/*.bin
	
# Boots the floppy.
boot:
	echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWelcome to CrepeOS. Booting now..."
	qemu-system-x86_64 -cdrom image/crepeos.iso

# Boots the floppy with dosbox-debug.
bootdebug:
	qemu-system-i386 -cdrom image/crepeos.iso

