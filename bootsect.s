	org		0x7c00	; boot sector

entry:
	; now loading from disk
	mov		cx, 3		; retry count
	mov		ax, 0x0000
	mov		ds, ax
	mov		ax, 0x9050
	mov		es, ax		; set es, the destination
	mov		bx, 0
loaddisk:
	mov		si, cx
	mov		ah, 0x02	; function: read disk sectors
	mov		al, 8		; sector count
	mov		dh, 0		; head
	mov		dl, 0		; drive number
	mov		ch, 0		; track 
	mov		cl, 2		; sector offset
	int		0x13
	jnc		loadok
	mov		bl, al
	call	putcharhex
	mov		cx, si
	loop	loaddisk

	; load failed
	mov		ah, 0x0e
	mov		al, 'X'
	int		0x10
	jmp		$

	; load OK
loadok:
	mov		ah, 0x0e
	mov		al, 'P'
	int		0x10
	mov		al, 'R'
	int		0x10
	mov		al, 'E'
	int		0x10
	mov		al, 'Y'
	int		0x10
	mov		al, 'O'
	int		0x10
	mov		al, 'T'
	int		0x10
	mov		ax, 0x9050
	mov		ds, ax
	mov		es, ax
	mov		ss, ax
	db		0xEA
	dd		0x90500000

%include "basic.s"
