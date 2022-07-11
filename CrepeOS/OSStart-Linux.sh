# This script is for the CrepeOS Installer, version 10.0
#!/bin/sh

if test "`whoami`" != "root" ; then
	echo -e "You must be logged in as root to build CrepeOS."
	echo -e "Enter 'su' or 'sudo bash' to switch to root."
	exit
fi

echo "Welcome to the CrepeOS v0.6b1 builder."
echo "WARNING. If you have data saved on the CrepeOS image, make a copy of the image now. Pressing any key will replace the installation with a fresh new one. If you have the file saved elsewhere, place it into the 'other' folder to include it on your new installation. Please back up any data you would like to keep NOW."
read -n 1 -s -r -p "Press any key to continue."

cd OS

echo -e "[building] Removing any existing image files"
rm -rf image/crepeos.flp
rm -rf image/crepeos.iso
sleep 0.5
if [ ! -e image/crepeos.flp ]
then
	echo "Creating floppy image"
	mkdosfs -C image/crepeos.flp 1440 || exit
fi


echo -e "[building] Assembling bootloader"

nasm -O0 -w+orphan-labels -f bin -o system/osldr/osldr.bin system/osldr/osldr.asm || exit
nasm -O0 -w+orphan-labels -f bin -o system/osldr/osclose.bin system/osldr/osclose.asm || exit

echo -e "[building] Assembling kernel"

cd system
nasm -O0 -w+orphan-labels -f bin -o oskrnl.bin oskrnl.asm || exit
cd ..

echo -e "[building] Assembling programs"

cd program

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done
cd ..

echo -e "[building] Adding bootloader to floppy image"

dd status=noxfer conv=notrunc if=system/osldr/osldr.bin of=image/crepeos.flp || exit

echo -e "[building] Copying files to image"

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image/crepeos.flp tmp-loop && cp system/oskrnl.bin tmp-loop/

cp program/*.bin program/*.bas tmp-loop


sleep 0.5

echo -e "[building] Unmounting loopback floppy"

umount tmp-loop || exit

echo "[building] Removing any temporary files used"

rm -rf tmp-loop

sleep 0.25

echo -e "[building] Creating CD-ROM ISO image"

rm  image/crepeos.iso
mkisofs -quiet -V 'CrepeOSISO' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.flp image/ || exit
sleep 0.25

echo -e '[done] Starting CrepeOS now via QEMU...'
cd image
qemu-system-x86_64 -cdrom crepeos.iso
