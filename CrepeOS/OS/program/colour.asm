;COLOUR.ASM 
;
;Assembled using AD86 combination inside an MS-DOS prompt.
;
;start:
	pushf			;Save used registers.
	push	ax		;
	push	bx		;
	push	cx		;
	mov	ax,0920h	;Set the character to SPACE for interrupt
				;using function ah = 09h...
	mov	bh,00h		;Set the page to be written to.
	mov	bl,07h		;Set to white on black.
	mov	cx,01h		;Just print one character unless changed.
	int	10h		;Trigger the interrupt.
	pop	cx		;Return registers back
	pop	bx		;
	pop	ax		;
	popf			;
	ret			;Return to the calling routine...
;end:
;End of subroutine...