global _char_vga_get_cursor
global _char_vga_set_cursor
global _char_vga_tobios
global _char_vga_frombios
global _char_vga_memread	; NOT A FUNCTION!
global _char_vga_memwrite	; NOT A FUNCTION!
global _char_vga_cursor_x
global _char_vga_cursor_y

global _chv_memread
global _chv_memwrite

_char_vga_cursor_x: dw 0
_char_vga_cursor_y: dw 0

_char_vga_get_cursor:
	push	bp
	mov		bp, sp
	xor		cx, cx			; cx=result

	mov		dx, 0x3D4
	mov		al, 0x0E
	out		dx, al			; read high byte

	mov		dx, 0x3D5
	in		al, dx
	mov		ch, al

	mov		dx, 0x3D4
	mov		al, 0x0F
	out		dx, al			; read low byte

	mov		dx, 0x3D5
	in		al, dx
	mov		cl, al

	mov		ax, cx			; set return value

	mov		sp, bp
	pop		bp
	ret


_char_vga_set_cursor:
	push	bp
	mov		bp, sp
	mov		cx, [bp+4]		; cx=argument

	mov		dx, 0x3D4
	mov		al, 0x0E
	out		dx, al			; send high byte

	mov		dx, 0x3D5
	mov		al, ch
	out		dx, al

	mov		dx, 0x3D4
	mov		al, 0x0F
	out		dx, al			; send low byte

	mov		dx, 0x3D5
	mov		al, cl
	out		dx, al

	mov		sp, bp
	pop		bp
	ret

_char_vga_tobios:
	push	bp
	mov		bp, sp
	
	mov		cx, bx		; preserve bx

	mov		ah, 0x0f
	int		0x10		; bh is set by int 0x10, ah=0x0f
	mov		dl, [_char_vga_cursor_x]
	mov		dh, [_char_vga_cursor_y]
	mov		ah, 0x02
	int		0x10

	mov		bx, cx		; restore bx

	mov		sp, bp
	pop		bp
	ret
	
_char_vga_frombios:
	push	bp
	mov		bp, sp
	
	mov		cx, bx		; preserve bx

	mov		ah, 0x0f
	int		0x10		; bh is set by int 0x10, ah=0x0f
	mov		[_char_vga_cursor_x], dl
	mov		[_char_vga_cursor_y], dh
	mov		ah, 0x03
	int		0x10

	mov		bx, cx		; restore bx

	mov		sp, bp
	pop		bp
	ret

_char_vga_memread:		; al=result, bx=addr
	mov		dx, 0xb800
	mov		fs, dx
	mov		al, [fs:bx]
	ret

_char_vga_memwrite:		; al=value, bx=addr
	mov		dx, 0xb800
	mov		fs, dx
	mov		[fs:bx], al
	ret

_chv_memread:
	push	bp
	mov		bp,sp

	mov		bx, [bp+4]
	call	_char_vga_memread
	xor		ah, ah

	mov		sp, bp
	pop		bp
	ret	
	
_chv_memwrite:
	push	bp
	mov		bp,sp

	mov		bx, [bp+4]
	mov		al, [bp+6]
	call	_char_vga_memwrite

	mov		sp, bp
	pop		bp
	ret	
