global _char_vga_get_cursor
global _char_vga_set_cursor
global _char_vga_cursor_x
global _char_vga_cursor_y

_char_vga_cursor_x: dd 0
_char_vga_cursor_y: dd 0

_char_vga_get_cursor:
	push	ebp
	mov		ebp, esp
	xor		ecx, ecx			; cx=result

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

	mov		eax, ecx			; set return value

	mov		esp, ebp
	pop		ebp
	ret


_char_vga_set_cursor:
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]		; cx=argument

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

	mov		esp, ebp
	pop		ebp
	ret
