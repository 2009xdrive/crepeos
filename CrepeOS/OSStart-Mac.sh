#!/bin/bash -u

if test "`whoami`" != "root" ; then
    echo -e "You must be logged in as root to build CrepeOS."
    echo -e "Enter 'su' or 'sudo bash' to switch to root."
    exit
fi

echo "Welcome to the CrepeOS v0.6b1 builder."
echo "WARNING. If you have data saved on the CrepeOS image, make a copy of the image now. Pressing any key will replace the installation with a fresh new one. If you have the file saved elsewhere, place it into the 'other' folder to include it on your new installation. Please back up any data you would like to keep NOW."
read -n 1 -s -r -p "Press any key to continue."

vercomp() {
    [ "$1" = "$2" ] && return 0

    local IFS=.
    local i ver1=($1) ver2=($2)
    unset IFS
    if [ "${#ver1[@]}" -ne "${#ver2[@]}" ]; then
        echo "[halt] versions being compared don't have the same form!" >&2
        echo "[halt] '$1' vs '$2'" >&2
        exit 1
    fi

    for ((i = 0; i < ${#ver1[@]}; ++i)); do
        (( ${ver1[i]} > ${ver2[i]} )) && return 1
        (( ${ver1[i]} < ${ver2[i]} )) && return 2
    done

    return 0
}

nasm_version_check () {
    vercomp $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [ $op = '=' ] || [ $op = '>' ]; then
        echo "[okay] nasm version at least '$2'"
        return 0
    else
        echo "[halt] nasm version is too low" >&2
        return 1
    fi
}

# Main
declare -r NASM_VER_REGEX='[0-9]+\.[0-9]+\.[0-9]+'
declare -r MINIMUM_NASM_VERSION=2.10.09
declare -r NASM_PATH=$(which nasm)

declare current_nasm_version=

if [ -z "$NASM_PATH" ]; then
	echo "[halt] nasm was not found on the system."
	exit 1
fi

current_nasm_version=$(nasm -v)

[ $? -ne 0 ] && echo '[halt] error calling nasm' >&2 && exit 1 

if [[ "$current_nasm_version" =~ $NASM_VER_REGEX ]]; then
    current_nasm_version=${BASH_REMATCH[0]}
    echo "[okay] found current nasm version of '$current_nasm_version'"
else
    echo "[halt] could not determine nasm version" >&2
    exit 1
fi

nasm_version_check "$current_nasm_version" "$MINIMUM_NASM_VERSION"
	
[ $? -ne 0 ] && echo "[halt] nasm not found or version is incompatible" >&2 && exit 1

cd OS

"$NASM_PATH" -O0 -f bin -o system/osldr/osldr.bin system/osldr/osldr.asm || exit 1
echo "[okay] assembled bootloader"

cd system
"$NASM_PATH" -O0 -f bin -o oskrnl.bin oskrnl.asm || exit 1
echo "[okay] assembled kernel"
cd ..

cd program
for i in *.asm; do
	"$NASM_PATH" -O0 -f bin $i -o "$(basename $i .asm).bin" || exit 1
	echo "[okay] assembled program: $i"
done
echo "[okay] assembled all programs"
cd ..

cp image/crepeos.flp image/crepeos.dmg
echo "[okay] copied floppy image"

dd conv=notrunc if=system/osldr/osldr.bin of=image/crepeos.dmg || exit 1
echo "[okay] added bootloader to image"

tmp_file=$(mktemp -d /tmp/$(basename $0).XXXXXX)
[ $? -ne 0 ] && echo "[halt] error creating a temp file" >&2 && exit 1

dev=$(echo -n $(hdid -nobrowse -nomount image/crepeos.dmg))
[ $? -ne 0 ] && echo "[halt] could not create disk from image" >&2 && exit 1

mount -t msdos "$dev" "$tmp_file"
[ $? -ne 0 ] && echo "[halt] could not mount "$dev"" >&2 && exit 1

cp system/oskrnl.bin "$tmp_file/"
cp program/*.bin program/*.bas program/*.dat program/*.hex "$tmp_file"
echo "[okay] added programs to image"

diskutil umount "$tmp_file"
hdiutil detach "$dev"
rm -rf "$tmp_file"
echo "[okay] unmounted floppy image"

rm -f image/crepeos.iso
mkisofs -quiet -V 'crepeos' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.dmg image/ || exit 1
echo "[okay] converted floppy to ISO-8859-1 image"
echo "[done] build completed"
echo -e '[done] starting CrepeOS now via QEMU...'
cd image
qemu-system-x86_64 -cdrom crepeos.iso
