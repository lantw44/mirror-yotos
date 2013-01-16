global _getch
global getch

_getch:
	push	bp
	mov		bp, sp
	mov		ah, 0x0
	int		0x16
	mov		sp, bp
	pop		bp
	ret
	
