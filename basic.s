putcharhex:			; bl=argument
	pusha
	mov		ah, 0x0e
	mov		al, bl
	and		al, 0xf0
	shr		al, 4
	call	fourbit2hex
	int		0x10
	mov		al, bl
	and 	al, 0x0f
	call	fourbit2hex
	int		0x10
	popa
	ret
fourbit2hex:		; al=argument=result
	cmp		al, 10
	jae		fourbit2hex_alpha
	add		al, '0'
	ret
fourbit2hex_alpha:
	add		al, 'A'
	sub		al, 10
	ret	

