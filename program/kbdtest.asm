%INCLUDE "crepeos.inc"

start:
	call .draw_background

	mov ax, .options
	mov bx, .optmsg
	mov cx, .blank
	call os_list_dialog
	
	jc .exit
	
	pusha
	mov ax, .exit_msg
	mov bx, 0
	mov cx, 0
	mov dx, 0
	call os_dialog_box
	call os_clear_screen
	popa
	
	cmp ax, 1
	je near .test1
	
	cmp ax, 2
	je near .test2
	
	cmp ax, 3
	je near .test3
	
	cmp ax, 4
	je near .test4
	
.test4:
	mov ah, 10h
	int 16h
	cmp al, "Q"
	je near start
	
	push ax
	
	mov bx, 100h
	mov dx, 0
	div bx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	mov ax, dx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	
	pop ax
	call os_print_4hex
	
	call os_print_newline
	jmp .test4
	
.test1:
	mov ah, 0
	int 16h
	cmp al, "Q"
	je near start
	
	push ax
	
	mov bx, 100h
	mov dx, 0
	div bx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	mov ax, dx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	
	pop ax
	call os_print_4hex
	
	call os_print_newline
	jmp .test1

.test2:
	mov ah, 1
	int 16h
	
	jz .2nokey			; If no key, skip to end

	mov ax, 0			; Otherwise get it from buffer
	int 16h

.2nokey:
	cmp al, "Q"
	je near start
	
	push ax
	
	mov bx, 100h
	mov dx, 0
	div bx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	mov ax, dx
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .space
	call os_print_string
	
	pop ax
	call os_print_4hex
	
	call os_print_newline
	jmp .test2
	
.test3:
	mov al, [fs:0417h]
	call os_print_2hex
	mov al, [fs:0418h]
	call os_print_2hex
	
	mov ah, 1
	int 16h
	jz .3nokey			; If no key, skip to end

	mov ax, 0			; Otherwise get it from buffer
	int 16h

.3nokey:
	cmp al, "Q"
	je near start
	
	jmp .test3
	
.exit:
	ret

.draw_background:	
	mov ax, .title
	mov bx, .blank
	mov cx, 256
	call os_draw_background
	ret
	
	.title			db 'CrepeOS Keyboard Diagnostic Tool', 0
	.optmsg			db 'Choose an option...', 0
	.options		db 'INT 16h (00h) - Slow key test,INT 16h (01h) - Fast key test,INT 16h (02h) - Modifier key test,INT 16h (10h) - Slow key test (AT)', 0
	.blank			db 0
	
	.space			db ' ', 0
	.exit_msg		db 'Press Shift+Q to quit.', 0

buffer:
