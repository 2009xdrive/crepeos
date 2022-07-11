   
; OS shutdown program for CrepeOS

    org 0x7c00
    jmp os_shutdown  ; Jumps to the code that will prepare for power off

os_shutdown:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15		 ; BIOS interrupt, indicating shutdown sequence. On compatible
			 ; computers, this will automatically turn the power off as well.

times 510-($-$$) db	 ; Pad the rest of the program with zeroes, to total 512 bytes
dw 0xaa55 		 ; BIOS signature indicating an OS shutdown program