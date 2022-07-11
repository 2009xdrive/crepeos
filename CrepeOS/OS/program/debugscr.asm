
	BITS 16
	%INCLUDE "cdev.inc"
	ORG 32768


start:

	mov cx, 00010000b
	call os_draw_background
	mov ax, stop_str	

	call os_print_1hex
	call os_print_2hex
	call os_print_4hex
		
	call os_dump_registers


	stop_str	db 'An error occurred. Please restart your computer.', 0