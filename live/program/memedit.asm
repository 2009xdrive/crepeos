
	%INCLUDE "crepeos.inc"

start:
	call .draw_background
	
	mov dl, 11
	mov dh, 4
	call os_move_cursor
	
	mov al, 0

.hexcharsloop1:
	call os_print_2hex
	call os_print_space
	
	inc al
	cmp al, 16
	jl .hexcharsloop1
	
	call os_print_space
	mov al, 0
	
.hexcharsloop2:
	call os_print_1hex
	
	inc al
	cmp al, 16
	jl .hexcharsloop2
	
.loop:
	call .draw

	lodsb
	cmp al, 'Q'				; 'Q' typed?
	je near .exit
	cmp al, 'O'
	je near .inputaddress
	cmp al, 'S'
	je near .inputsegment
	cmp al, 'D'
	je near .inputdata
	cmp al, 'H'
	je near .help
	cmp al, 'W'
	je near .save
	cmp al, 'L'
	je near .load
	jmp .loop
	
.save:
	lodsb
	cmp al, 'D'
	je near .savedecimal
	cmp al, 'H'
	je near .savehexadecimal
	jmp .loop
	
.savedecimal:
	sub si, 2
	call os_string_parse
	add ax, 2
	mov si, ax
	call os_string_to_int
	
	jmp .copy
	
.savehexadecimal:
	sub si, 2
	call os_string_parse
	add ax, 2
	mov si, ax
	call os_string_to_hex
	
.copy:
	mov cx, ax		; File size
	mov ax, bx		; Filename
	
	; Save the file

	push es
	mov es, [.segment]
	mov bx, [.offset]
	call os_write_file
	pop es
	
	jc .error
	
	jmp .loop	

.load:
	mov ax, si
	
	push es
	mov es, [.segment]
	mov cx, [.offset]
	call os_load_file
	pop es
	
	jc .error
	
	jmp .loop	


.help:
	mov ax, .help_msg0
	mov bx, .help_title0
	mov cx, .help_title1
	call os_list_dialog
	
	jmp start
	
.inputaddress:
	lodsb
	cmp al, 'D'
	je near .addressdecimal
	cmp al, 'H'
	je near .addresshexadecimal
	jmp .loop
	
.addressdecimal:
	call os_string_to_int
	mov [.offset], ax
	jmp .loop
	
.addresshexadecimal:
	call os_string_to_hex
	mov [.offset], ax
	jmp .loop
	
.inputsegment:
	lodsb
	cmp al, 'D'
	je near .segmentdecimal
	cmp al, 'H'
	je near .segmenthexadecimal
	jmp .loop
	
.segmentdecimal:
	call os_string_to_int
	mov [.segment], ax
	jmp .loop
	
.segmenthexadecimal:
	call os_string_to_hex
	mov [.segment], ax
	jmp .loop
	
.inputdata:
	lodsb
	cmp al, 'D'
	je near .datadecimal
	cmp al, 'H'
	je near .datahexadecimal
	jmp .loop
	
.datadecimal:
	mov byte [.data_mode], 1
	call .draw
	mov byte [.data_mode], 0
	
	cmp byte [si], 'Q'
	je .loop

	call os_string_to_int
	
	push es
	mov si, [.offset]
	mov es, [.segment]
	mov [es:si], al
	pop es

	inc word [.offset]
	
	jmp .datadecimal
	
.datahexadecimal:
	mov byte [.data_mode], 1
	call .draw
	mov byte [.data_mode], 0
	
	cmp byte [si], 'Q'
	je .loop

	call os_string_to_hex

	push es
	mov si, [.offset]
	mov es, [.segment]
	mov [es:si], al
	pop es

	inc word [.offset]
	
	jmp .datahexadecimal
	
.draw:
	call .bardraw
	
	call .datadraw
	
	call .asciidraw
	
	mov dl, 0				; Print the input label
	mov dh, 2
	call os_move_cursor
	cmp byte [.data_mode], 0
	je .normal_label
	
	mov si, .data_label
	call os_print_string
	
	jmp .finish_label
	
.normal_label:
	mov si, .input_label
	call os_print_string
	
.finish_label:
	mov ah, 09h				; Clear the screen for the next input
	mov al, ' '
	mov bh, 0
	mov bl, [57000]
	mov cx, 60
	int 10h
	
	mov dl, 40
	mov dh, 2
	call os_move_cursor
	
	mov ax, [.segment]
	call os_print_4hex
	
	mov si, .semicolon
	call os_print_string
	
	mov ax, [.offset]
	call os_print_4hex

	mov dl, 2
	mov dh, 2
	call os_move_cursor
	call os_show_cursor		; Get a command from the user
	mov ax, .input_buffer
	call os_input_string
	
	mov si, .input_buffer	; Decode the command
	call os_string_uppercase

	ret
	
.asciidraw:
	pusha
	
	mov dl, 60
	mov dh, 6
	call os_move_cursor

	push es
	mov si, [.offset]
	sub si, 40h
	mov es, [.segment]
	
	and si, 0FFF0h			; Mask off the lowest 4 bits
	
.asciiloop:
	mov al, [es:si]
	inc si

	cmp al, 32
	jge near .asciichar
	mov al, '.'
	
.asciichar:
	mov ah, 0Eh
	mov bh, 0
	int 10h
	
	call os_get_cursor_pos
	cmp dl, 76
	jl .asciiloop
	
	mov dl, 60
	inc dh	
	call os_move_cursor

	cmp dh, 22
	jl .asciiloop
	
	pop es
	
	popa
	ret

.datadraw:
	pusha

	mov dl, 11
	mov dh, 6
	call os_move_cursor
	
	push es
	
	mov si, [.offset]
	sub si, 40h
	mov es, [.segment]
	
	and si, 0FFF0h			; Mask off the lowest 4 bits

.dataloop:
	mov al, [es:si]
	inc si
	
	call os_print_2hex
		
	call os_print_space
		
	call os_get_cursor_pos
	cmp dl, 59
	jl .dataloop
	
	mov dl, 11
	inc dh	
	call os_move_cursor

	cmp dh, 22
	jl .dataloop
	
	pop es
	
	popa
	ret
	
.exit:
	call os_clear_screen
	ret

.draw_background:
	mov ax, .title_msg
	mov bx, .footer_msg
	mov cx, [57000]
	call os_draw_background
	ret

.bardraw:
	mov dl, 0
	mov dh, 6
	call os_move_cursor
	
	mov ax, [.offset]
	and ax, 0FFF0h
	sub ax, 40h

	mov bx, [.segment]
	
	mov cl, 0

	mov si, .semicolon

.barloop:
	call os_print_space
	
	xchg ax, bx
	call os_print_4hex
	call os_print_string
	xchg ax, bx
	call os_print_4hex

	call os_print_newline
	
	add ax, 16
	
	inc cl
	cmp cl, 16
	jne .barloop
	
	ret
	
.error:
	mov ax, .error_msg
	mov bx, 0
	mov cx, 0
	mov dx, 0
	call os_dialog_box
	jmp start
	
; DAAAAAAATAAAAAAA!
	
	.title_msg			db 'CrepeOS Memory Editor', 0
	.footer_msg			db '[h], [Enter] = Command list', 0
	
	.input_label		db ' >', 0
	.data_label			db 'D>', 0
	
	.data_mode			db 0
	.offset				dw 0
	.segment			dw 0

	.semicolon			db ':', 0
	
	.help_title0		db 'Command list:', 0
	.help_title1		db 0
	.help_msg0			db 'q = Quit,'
	.help_msg1			db 'sd/shXXXX = Set the 16-bit segment (dec/hex),'
	.help_msg2			db 'od/ohXXXX = Set the 16-bit offset (dec/hex),'
	.help_msg3			db 'dd/dh = Enter the data write mode (dec/hex),'
	.help_msg4			db 'wd/whXXXX ABC.XYZ = Write a file (XXXX bytes; filename ABC.XYZ),'
	.help_msg5			db 'lABC.XYZ = Load a file (filename ABC.XYZ)', 0
	.error_msg			db 'File access error!', 0
	
	.input_buffer		db 0		; Has to be on the end!
; ------------------------------------------------------------------

