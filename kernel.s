	global	_main

_main:
	mov		sp, 0x3ffe
;--------------------------------------------------
set_environment:
	xor		ax, ax
	push	es
	mov		es, ax
	db		0xE8
	add		al, [bx+si]
	db		0xEB
	db		0x05
	pop		ax
	sub		sp, 2
	ret
;--------------------------------------------------
do_memory_control:
	add		ax, 0x17
	cli
	mov		[es:0x140], ax
	mov		[es:0x142], cs
	sti
	jmp		do_memory_control_end
	mov		ax, 0x5301 
	xor		bx, bx 
	int		0x15 
	mov		ax, 0x530E 
	xor		bx, bx 
	mov		cx, 0x0102 
	int		0x15 
	mov		ax, 0x5307
	mov		bx, 0x0001
	mov		cx, 0x0003 
	int		0x15
	iret
do_memory_control_end:
	pop		es
;--------------------------------------------------
set_keyboard:
	xor		ax, ax
	push	es
	mov		es, ax
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	db		0xE8
	add		al, [bx+si]
	db		0xEB
	db		0x05
	pop		ax
	sub		sp, 2
	ret
	add		ax, 0x2C
	cli
	mov		si, [es:0x24]
	mov		di, [es:0x26]
	mov		[es:0x324], si
	mov		[es:0x326], di
	mov		[es:0x24], ax
	mov		[es:0x26], cs
	sti
	jmp		near set_keyboard_end
	
code_for_scancode:
	push	ax
	push	bx
	push	es
	mov		ax, 0x40
	mov		es, ax
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, '['
	int		0x10
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		ax, [es:0x1A]
	call	putint
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, ','
	int 	0x10
	
	mov		ax, [es:0x1C]
	mov		dx, ax
	call	putint
	

	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, ']'
	int 	0x10

	pop		es
	pop		bx
	pop		ax
	int		0xC9
	iret
set_keyboard_end:
	pop		es
;--------------------------------------------------	
load_bin_from_floppy:
	xor		ax, ax
	mov		ax, 0x0050
	mov		es, ax
	mov		bx, 0x0000
	; start loading
	mov		si, cx
	mov		ah, 0x02	; function: read disk sectors
	mov		al, 8		; sector count
	mov		dh, 0		; head
	mov		dl, 0		; drive number
	mov		ch, 0		; track 
	mov		cl, 10		; sector offset
	int		0x13
	jc 		load_bin_failed
;--------------------------------------------------
view_loader_message:
	mov		ah, 0x0e
	mov		al, ':'
	mov		bx, 0x0007
	int		0x10
	mov		al, 0x0d
	int		0x10
	mov		al, 0x0a
	int		0x10
;--------------------------------------------------
fake_loader:
	db		0xE8
	add		al, [bx+si]
	db		0xEB
	db		0x05
	db		0x58
;--------------------------------------------------
virtual_device:
	db		0x83
	in		al, dx
	db		0x02
	ret
;--------------------------------------------------
real_loader:
	jmp		near very_very_far_func
	jmp		program_exit
;--------------------------------------------------
load_bin_failed:
	mov		dx, 0
	mov		ds, dx		
	mov		es, dx
	xor		ah, al
	call	putint
	jmp		_main
;--------------------------------------------------
program_exit:
	mov		bx, cs
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	mov		si, 0x3FFE
	mov		sp, [si]
	mov		dx, ax
;	pop		dx
;	call	char_vga_setbios
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 0x0D
	int		0x10
	mov		al, 0x0A
	int		0x10
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 'E'
	int		0x10
	mov		al, 'x'
	int		0x10
	mov		al, 'i'
	int		0x10
	mov		al, 't'
	int		0x10
	mov		al, ' '
	int		0x10
	mov		al, 'C'
	int		0x10
	mov		al, 'o'
	int		0x10
	mov		al, 'd'
	int		0x10
	mov		al, 'e'
	int		0x10
	mov		al, ':'
	int		0x10
	mov		al, ' '
	int		0x10

	mov		ax, dx
	call	putint
	
;	mov		ax, dx
;	call	putint
	
;	mov		ax, dx
;	call	putint
	
	int 	0x10
	db		0xEB, 0xFE
	jmp		_main
;--------------------------------------------------
putint:				; ax=argument
	pusha
	mov		di, 0	; dest index
	mov		si, 10	; divisor, ax=dividend
	
	putint_divloop:
		mov		dx, 0	; clear upper bits
		div		si
		add		dx, '0'
		mov		byte [putintbuf+di], dl
		inc		di
		cmp		ax, 0
		ja		putint_divloop

	mov		ah, 0x0e
	mov		bx, 0x0007
	
	putint_print:
		dec		di
		mov		al, byte [putintbuf+di]
		int		0x10
		cmp		di, 0
		ja		putint_print

	popa
	ret
;--------------------------------------------------
very_very_far_func:
;	call	char_vga_savebios
;	push	dx
	mov		si, 0x3FFE
	mov		[si], sp
	
	mov		bx, 0x0050
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	mov		bx, 0xFFFF
	mov		si, bx
	mov		dx, 0xFFF8
	mov		sp, dx
	mov		bp, dx
	
	mov		[si-0x0001], cs
	add		ax, 0x0A
	mov		[si-0x0003], ax
	mov		dl, 0xFA
	mov		[si-0x0007], dx
	mov		dl, 0x5A
	mov		[si-0x0005], dl
	mov		dl, 0xCB
	mov		[si-0x0004], dl

	jmp		0x0050:0x0000
;--------------------------------------------------
char_vga_setbios:
	mov		cx, bx		; preserve bx
	mov		ah, 0x0f
	int		0x10		; bh is set by int 0x10, ah=0x0f
	mov		ah, 0x02
	int		0x10
	mov		bx, cx		; restore bx
	ret
	
char_vga_savebios:
	mov		cx, bx		; preserve bx
	mov		ah, 0x0f
	int		0x10		; bh is set by int 0x10, ah=0x0f
	mov		ah, 0x03
	int		0x10
	mov		bx, cx		; restore bx
	ret
	
putintbuf: times 5 db 0
