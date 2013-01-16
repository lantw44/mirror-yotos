global _putint
global putcharhex
global _putcharhex
global putstr
global _putstr

_putint:
	push	bp
	mov		bp, sp
	mov		ax, word [bp+4]		; ax=argument
	sub		sp, 8				; 5 bytes - printing buffer
	pusha
	mov		di, -1	; dest index
	mov		si, 10	; divisor, ax=dividend
putint_divloop:
		mov		dx, 0	; clear upper bits
		div		si
		add		dx, '0'
		mov		byte [bp+di], dl
		dec		di
		cmp		ax, 0
		ja		putint_divloop

	mov		ah, 0x0e
	mov		bx, 0x0007
putint_print:
		inc		di
		mov		al, byte [bp+di]
		int		0x10
		cmp		di, -1
		jl		putint_print

	popa
	mov		sp, bp
	pop		bp
	ret


_putcharhex:
	push	bp
	mov		bp, sp
	mov		cl, byte [bp+4]
	call	putcharhex
	mov		sp, bp
	pop		bp
	ret

putcharhex:			; cl=argument
	mov		dx, bx	; preserve bx
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, cl
	and		al, 0xf0
	shr		al, 4
	call	fourbit2hex
	int		0x10
	mov		al, cl
	and 	al, 0x0f
	call	fourbit2hex
	int		0x10
	mov		bx, dx	; restore bx
	ret

fourbit2hex:		; al=argument=result
	cmp		al, 10
	jae		fourbit2hex_alpha
	add		al, '0'
	ret
fourbit2hex_alpha:
	add		al, 'A' - 10
	ret	


_putstr:
	push	bp
	mov		bp, sp
	mov		dx, word [bp+4]
	call	putstr
	mov		sp, bp
	pop		bp
	ret

putstr:				; dx=argument
	mov		cx, bx	; we must preserve bx
putstr_start:
	mov		bx, dx	; [dx] is not a effective address
	mov		al, byte [bx]
	test	al, al
	jz		putstr_end
	mov		ah, 0x0e
	mov		bx, 0x0007
	int		0x10
	inc		dx
	jmp		putstr_start
putstr_end:
	mov		bx, cx
	ret

