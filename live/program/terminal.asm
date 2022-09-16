
	%INCLUDE "crepeos.inc"

start:
	call os_clear_screen
	
	mov si, terminal_name
	mov di, 00F0h
	call os_string_copy
	
	mov byte [0082h], 1
	
	cmp byte [7FFEh], 0
	je .no_return
	
	mov byte [7FFEh], 0
	
	jmp get_cmd
	
.no_return:
	mov si, version_msg
	call os_print_string
	mov si, help_msg
	call os_print_string

get_cmd:				; Main processing loop
	mov di, 3072			; Clear input buffer each time
	mov al, 0
	mov cx, 256
	rep stosb

	mov di, command			; And single command buffer
	mov cx, 32
	rep stosb

	mov si, prompt			; Main loop; prompt for input
	call os_print_string

	mov ax, 3072			; Get command string from user
	call os_input_string

	call os_print_newline

	mov ax, 3072			; Remove trailing spaces
	call os_string_chomp

	mov si, 3072			; If just enter pressed, prompt again
	cmp byte [si], 0
	je get_cmd

	mov si, 3072			; Separate out the individual command
	mov al, ' '
	call os_string_tokenize

	mov word [param_list], di	; Store location of full parameters

	mov si, 3072			; Store copy of command for later modifications
	mov di, command
	call os_string_copy

	; First, let's check to see if it's an internal command...

	mov ax, 3072
	call os_string_uppercase

	mov si, 3072

	mov di, exit_string		; 'EXIT' entered?
	call os_string_compare
	jc near exit

	mov di, help_string		; 'HELP' entered?
	call os_string_compare
	jc near print_help

	mov di, cls_string		; 'CLS' entered?
	call os_string_compare
	jc near clear_screen

	mov di, dir_string		; 'DIR' entered?
	call os_string_compare
	jc near list_directory

	mov di, la_string		; 'LA' entered?
	call os_string_compare
	jc near la_directory

	mov di, ver_string		; 'VER' entered?
	call os_string_compare
	jc near print_ver

	mov di, time_string		; 'TIME' entered?
	call os_string_compare
	jc near print_time

	mov di, date_string		; 'DATE' entered?
	call os_string_compare
	jc near print_date

	mov di, cat_string		; 'CAT' entered?
	call os_string_compare
	jc near cat_file

	mov di, del_string		; 'DEL' entered?
	call os_string_compare
	jc near del_file

	mov di, copy_string		; 'COPY' entered?
	call os_string_compare
	jc near copy_file

	mov di, ren_string		; 'REN' entered?
	call os_string_compare
	jc near ren_file

	mov di, size_string		; 'SIZE' entered?
	call os_string_compare
	jc near size_file

	; If the user hasn't entered any of the above commands, then we
	; need to check for an executable file -- .APP or .BAS, and the
	; user may not have provided the extension

	mov ax, command
	call os_string_uppercase
	call os_string_length


	; If the user has entered, say, MEGACOOL.APP, we want to find that .APP
	; bit, so we get the length of the command, go four characters back to
	; the full stop, and start searching from there

	mov si, command
	add si, ax

	cmp byte [si], 0
	je no_extension

	sub si, 4

	mov di, bin_extension		; Is there a .BIN extension?
	call os_string_compare
	jc execute_bin

	mov di, bas_extension		; Or is there a .BAS extension?
	call os_string_compare
	jc bas_file

	jmp total_fail
	
execute_bin:
	mov byte [32767], 1
	mov byte [32766], 1
	
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0
	je .no_parameters
	
	call os_string_uppercase
	
	mov si, ax
	mov di, 0E0h
	call os_string_copy
	mov ax, command
	
	ret
	
.no_parameters:
	mov byte [0E0h], 0
	mov ax, command
	
	ret
	
bas_file:
	mov ax, command
	mov bx, 0
	mov cx, 4096
	call os_load_file
	jc total_fail

	mov ax, 4096
	mov word si, [param_list]
	call os_run_basic

	call os_clear_screen
	call os_show_cursor
	
	jmp get_cmd

no_extension:
	mov ax, command
	call os_string_length

	mov si, command
	add si, ax

	mov byte [si], '.'
	mov byte [si+1], 'A'
	mov byte [si+2], 'P'
	mov byte [si+3], 'P'
	mov byte [si+4], 0

	mov ax, command
	mov bx, 0
	mov cx, 4096
	call os_load_file
	jc try_bas_ext

	jmp execute_bin


try_bas_ext:
	mov ax, command
	call os_string_length

	mov si, command
	add si, ax
	sub si, 4

	mov byte [si], '.'
	mov byte [si+1], 'B'
	mov byte [si+2], 'A'
	mov byte [si+3], 'S'
	mov byte [si+4], 0

	jmp bas_file



total_fail:
	mov si, invalid_msg
	call os_print_string

	jmp get_cmd

; ------------------------------------------------------------------

print_help:
	mov si, dir_help
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

clear_screen:
	call os_clear_screen
	jmp get_cmd


; ------------------------------------------------------------------

print_time:
	mov bx, tmp_string
	call os_get_time_string
	mov si, bx
	call os_print_string
	call os_print_newline
	jmp get_cmd


; ------------------------------------------------------------------

print_date:
	mov bx, tmp_string
	call os_get_date_string
	mov si, bx
	call os_print_string
	call os_print_newline
	jmp get_cmd


; ------------------------------------------------------------------

print_ver:
	mov si, version_msg
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

la_directory:
	mov cx, 0

	mov ax, 16384		; Get comma-separated list of filenames
	call os_get_file_list

	; Replace all of the ','s with 0s, the end should end in 4 (ASCII: End of transmission)
	
	mov si, 16384
	mov di, 16384
	
.loop:
	lodsb
	cmp al, ','
	jne .no_comma
	
	mov al, 0
	jmp .mod_loop
	
.no_comma:
	cmp al, 0
	jne .mod_loop
	
	mov al, 0
	stosb
	mov al, 4
	stosb
	jmp .end
	
.mod_loop:
	stosb
	jmp .loop
	
.end:	
	mov si, 16384

.repeat:
	call os_print_string
	
	; Print file size
	
	pusha
	mov ax, si
	call os_get_file_size
	mov eax, ebx
	
	call os_get_cursor_pos
	mov dl, 20
	call os_move_cursor
	call os_32int_to_string
	mov si, ax
	call os_print_string
	mov si, size_file.size_msg
	call os_print_string
	popa
	
	; Print file date/time
	
	pusha
	mov ax, si
	call os_get_file_datetime

	call os_get_cursor_pos
	mov dl, 40
	call os_move_cursor

	mov ax, cx		; Days
	and ax, 11111b
	
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov si, dateseparator
	call os_print_string

	mov ax, cx		; Months
	shr ax, 5
	and ax, 1111b
	
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov si, dateseparator
	call os_print_string
	
	mov ax, cx		; Years
	shr ax, 9
	add ax, 1980
	
	call os_int_to_string
	mov si, ax
	call os_print_string

	call os_print_space
	
	mov ax, bx		; Hours
	shr ax, 11

	cmp ax, 10
	jge .no_hour_zero
	
	mov si, zerofill
	call os_print_string
	
.no_hour_zero:
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov si, timeseparator
	call os_print_string
	
	mov ax, bx		; Minutes
	shr ax, 5
	and ax, 111111b
	
	cmp ax, 10
	jge .no_minute_zero
	
	mov si, zerofill
	call os_print_string
	
.no_minute_zero:
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov si, timeseparator
	call os_print_string
	
	mov ax, bx		; Seconds
	and ax, 11111b
	shl ax, 1
	
	cmp ax, 10
	jge .no_second_zero
	
	mov si, zerofill
	call os_print_string
	
.no_second_zero:
	call os_int_to_string
	mov si, ax
	call os_print_string
	popa
	
	mov al, 0
	call os_find_char_in_string
	add si, ax
	
	cmp byte [si], 4
	je .done
	
	call os_print_newline
	inc cx
	cmp cx, 23
	jne .repeat
	
	call os_get_cursor_pos
	pusha
	mov dh, 24
	mov dl, 0
	call os_move_cursor
	mov si, wait_string
	call os_print_string
	call os_wait_for_key
	
	call os_move_cursor
	mov ax, 0920h
	mov bx, 7
	mov cx, 80
	int 10h	
	popa
	call os_move_cursor
	mov cx, 0
	jmp .repeat
	
.done:
	call os_print_newline
	jmp get_cmd


list_directory:
	mov ax, 16384			; Get comma-separated list of filenames
	call os_get_file_list

	mov si, 16384
	mov ah, 0Eh			; BIOS teletype function

	call os_get_cursor_pos
	mov dl, 0
	
.repeat:
	lodsb				; Start printing filenames
	cmp al, 0			; Quit if end of string
	je .done

	cmp al, ','			; If comma in list string, don't print it
	jne .nonewline
	
	add dl, 16
	cmp dl, 80
	jl near .newline
	mov dl, 0
	inc dh
	cmp dh, 25
	je near .scroll
	call os_print_newline
.newline:
	call os_move_cursor
	jmp .repeat
	
.nonewline:
	int 10h
	jmp .repeat
	
.scroll:
	mov dh, 24
	call os_print_newline
	jmp .newline
	
.done:
	call os_print_newline
	jmp get_cmd


; ------------------------------------------------------------------

cat_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, catnofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_file_exists		; Check if file exists
	jc .not_found

	mov cx, 4096			; Load file into second 32K
	call os_load_file

	mov word [file_size], bx

	cmp bx, 0			; Nothing in the file?
	je get_cmd

	mov si, 4096
	mov ah, 0Eh			; int 10h teletype function
.loop:
	lodsb				; Get byte from loaded file

	cmp al, 0Ah			; Move to start of line if we get a newline char
	jne .not_newline

	call os_get_cursor_pos
	mov dl, 0
	call os_move_cursor

.not_newline:
	int 10h				; Display it
	dec bx				; Count down file size
	cmp bx, 0			; End of file?
	jne .loop

	jmp get_cmd

.not_found:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

del_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, delnofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_remove_file
	jc .failure

	mov si, success_msg
	call os_print_string
	jmp get_cmd

.failure:
	mov si, writefail_msg
	call os_print_string
	jmp get_cmd

	
; ------------------------------------------------------------------

size_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, sizenofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_get_file_size
	jc .failure

	mov ax, bx
	call os_int_to_string
	mov si, ax
	call os_print_string

	mov si, .size_msg
	call os_print_string

	call os_print_newline
	jmp get_cmd


.failure:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd


	.size_msg	db ' bytes', 0


; ------------------------------------------------------------------

copy_file:
	mov word si, [param_list]
	call os_string_parse
	mov word [.tmp], bx

	cmp bx, 0			; Were two filenames provided?
	jne .filename_provided

	mov si, copynofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	mov dx, ax			; Store first filename temporarily
	mov ax, bx
	call os_file_exists
	jnc .already_exists

	mov ax, dx
	mov cx, 4096
	call os_load_file
	jc .load_fail

	mov cx, bx
	mov bx, 4096
	mov word ax, [.tmp]
	call os_write_file
	jc .write_fail

	mov si, success_msg
	call os_print_string
	jmp get_cmd

.load_fail:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd

.write_fail:
	mov si, writefail_msg
	call os_print_string
	jmp get_cmd

.already_exists:
	mov si, exists_msg
	call os_print_string
	jmp get_cmd


	.tmp		dw 0

	
; ------------------------------------------------------------------

ren_file:
	mov word si, [param_list]
	call os_string_parse

	cmp bx, 0			; Were two filenames provided?
	jne .filename_provided

	mov si, rennofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	mov cx, ax			; Store first filename temporarily
	mov ax, bx			; Get destination
	call os_file_exists		; Check to see if it exists
	jnc .already_exists

	mov ax, cx			; Get first filename back
	call os_rename_file
	jc .failure

	mov si, success_msg
	call os_print_string
	jmp get_cmd

.already_exists:
	mov si, exists_msg
	call os_print_string
	jmp get_cmd

.failure:
	mov si, .failure_msg
	call os_print_string
	jmp get_cmd

	.failure_msg	db 'File not found', 13, 10, 0


; ------------------------------------------------------------------

exit:
	ret

; ------------------------------------------------------------------

	command			times 32 db 0

	tmp_string		times 15 db 0

	file_size		dw 0
	param_list		dw 0
	wait_string		db 'Press any key to continue...', 0
	dateseparator	db '/', 0
	timeseparator	db ':', 0
	zerofill		db '0', 0
	
	
	bin_extension		db '.APP', 0
	bas_extension		db '.BAS', 0

	prompt			db '> ', 0

	dir_help		db 'LS      : List the directory', 13, 10
	la_help			db 'LL      : List the directory (with file sizes & date/time)', 13, 10
	copy_help		db 'CP      : Copy a file', 13, 10
	ren_help		db 'MV      : Rename a file', 13, 10
	del_help		db 'RM      : Delete a file', 13, 10
	cat_help		db 'CAT     : Dump the file on the screen', 13, 10
	size_help		db 'SIZE    : Tell a size of a file', 13, 10
	cls_help		db 'CLEAR   : Clear the screen', 13, 10
	help_help		db 'HELP    : Tell all the possible commands', 13, 10
	time_help		db 'TIME    : Tell the time', 13, 10
	date_help		db 'DATE    : Tell the date', 13, 10
	ver_help		db 'VER     : CrepeOS version', 13, 10
	exit_help		db 'EXIT    : Quit', 13, 10, 0
	
	terminal_name		db 'TERMINAL.APP', 0
	
	invalid_msg			db 'Invalid command', 13, 10, 0
	nofilename_msg		db 'Filaname missing', 13, 10, 0
	sizenofilename_msg	db 'Syntax: SIZE <filename>', 13, 10, 0
	catnofilename_msg	db 'Syntax: CAT <filename>', 13, 10, 0
	copynofilename_msg	db 'Syntax: COPY <filename> <new filename>', 13, 10, 0
	rennofilename_msg	db 'Syntax: REN <filename> <new filename>', 13, 10, 0
	delnofilename_msg	db 'Syntax: DEL <filename>', 13, 10, 0
	notfound_msg		db 'File not found.', 13, 10, 0
	writefail_msg		db 'Error writing to the disk.', 13, 10, 0
	success_msg			db 'Operation successfully finished', 13, 10, 0
	exists_msg			db 'File already exists!', 13, 10, 0

	version_msg		db 'CrepeOS v0.7b1', 13, 10, 0
	help_msg		db 'For more information type "HELP".', 13, 10, 0
	
	exit_string		db 'EXIT', 0
	help_string		db 'HELP', 0
	cls_string		db 'CLEAR', 0
	dir_string		db 'LS', 0
	time_string		db 'TIME', 0
	date_string		db 'DATE', 0
	ver_string		db 'VER', 0
	cat_string		db 'CAT', 0
	del_string		db 'RM', 0
	ren_string		db 'MV', 0
	copy_string		db 'CP', 0
	size_string		db 'SIZE', 0
	la_string		db 'LL', 0
	
; ==================================================================

