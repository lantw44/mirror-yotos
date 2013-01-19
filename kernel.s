	global	_main

_main:
	mov		sp, 0x7ffe
	mov		word [local_var_size],local_var_end
	sub		word [local_var_size],local_var_start
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
reboot_int:
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
	add		ax, 0x17
	cli
	mov		[es:0x144], ax
	mov		[es:0x146], cs
	sti
	jmp		short reboot_int_end
	mov		al, 0x0F
	out		0x64, al
	mov		ax,0x0040
	push	ax
	pop		ds
	xor		ax, ax
	mov		es, ax
	mov		word [es:0x0027], 0x1234
	mov		ax, 0xFFFF
	push	ax
	mov		ax, 0x0000
	push	ax
	mov		ax, 0x1000
	mov		ss, ax
	mov		sp, 0xf000
	mov		ax, 0x5307
	mov		bx, 0x0001
	mov		cx, 0x0003 
	int		0x15
reboot_int_end:
	pop		es
;--------------------------------------------------
set_keyboard_break:
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
	add		ax, 0x2C
	cli

	mov		si, [es:0x24]
	mov		di, [es:0x26]
	mov		[es:0x324], si
	mov		[es:0x326], di
	mov		[es:0x24], ax
	mov		[es:0x26], cs

	sti
	jmp		near set_keyboard_end_break
	int		0xC9
	iret

set_keyboard_end_break:
	pop		es
;--------------------------------------------------
set_timer:
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
	add		ax, 0x2C
	cli

	mov		si, [es:0x20]
	mov		di, [es:0x22]
	mov		[es:0x320], si
	mov		[es:0x322], di
	mov		[es:0x20], ax
	mov		[es:0x22], cs

	sti
	jmp		near set_timer_end
	int		0xC8
	pushf
	cli
;	pusha
;	mov		ah, 0x0E
;	mov		al, '!'
;	mov		bx, 0x0007
;	int		0x10
;	popa
	cmp		word [cs:break_imm],0x00
	
	je		update_timer
	
	cmp		word [cs:scancode_processing], 0x00
	jne		update_timer
	
	mov			word [cs:scancode_processing], 0x01
	mov			ax, [cs:sector_to_load_ax];
	cmp			word [cs:sector_to_load], 0x3021 ;
	jne			not_shell_load_break
	mov			ax, 0xFFFF
	jmp			shell_load_break
not_shell_load_break:
	mov			word [cs:sector_to_load], 0x3021
	sti
	popf
	jmp			program_exit_no_to_save
shell_load_break:
	sti
	popf
	jmp			program_exit
	
update_timer:
	inc		word [cs:view_step_now]
;	push	ax
;	mov		ax, 123
;	call	putint
;	pop		ax
view_screen_timer:
	cmp		word [cs:view_length], 0x00
	je		timer_ret
	cli
	push	ax
;	mov		ax, 123
;	call	putint
	push	cx
	mov		ax, [cs:view_step_now]
	and		ax, [cs:view_delaycnt]
	cmp		ax, [cs:view_original]
	jne		not_need_update_view
	push	es
	mov		ax, 0xB800
	mov		es, ax
	mov		ax, word [cs:view_screenbuffer]
	mov		cx, word [cs:view_screenbuffer+0x02]
	mov		word [es:0x009C], ax
	mov		word [es:0x009E], cx
	mov		word [cs:view_length], 0x00
	pop		es
not_need_update_view:
	pop		cx
	pop		ax
	sti
timer_ret:
	sti
	popf
	iret

set_timer_end:
	pop		es
;--------------------------------------------------

set_keyboard:
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
	add		ax, 0x2C
	cli
	mov		si, [es:0x54]
	mov		di, [es:0x56]
	mov		[es:0x354], si
	mov		[es:0x356], di
	mov		[es:0x54], ax
	mov		[es:0x56], cs

	sti
	jmp		near set_keyboard_end
code_for_scancode:
	pushf
	
;----------------------------------
	jnc		end_for_scancode
	cmp		ah, 0x4f
	jne		end_for_scancode
;----------------------------------

;----------------------------------
	mov		[cs:scancode_int_buf], al

	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	
	mov		ah, [cs:scancode_int_buf]

	mov		dx, cs
	mov		es, dx

	mov		dx, [es:scancodebuf-0x0C]
	mov		[es:scancodebuf-0x0E], dx
	
	mov		dx, [es:scancodebuf-0x0A]
	mov		[es:scancodebuf-0x0C], dx
	
	mov		dx, [es:scancodebuf-0x08]
	mov		[es:scancodebuf-0x0A], dx
	
	mov		dx, [es:scancodebuf-0x06]
	mov		[es:scancodebuf-0x08], dx
	
	mov		dx, [es:scancodebuf-0x04]
	mov		[es:scancodebuf-0x06], dx
	
	mov		dx, [es:scancodebuf-0x02]
	mov		[es:scancodebuf-0x04], dx
	
	mov		dx, [es:scancodebuf-0x00]
	mov		[es:scancodebuf-0x02], dx
	
	mov		[es:scancodebuf], ax
	mov		cx, 0x02
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x58
	je		f12_break
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x57
	je		f11_savescreen
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x44
	je		f10_loadscreen
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x43
	je		f9_showinfo
	
	lea		bx, [es:scancodebufp+0x09]
	
	cmp		byte [es:bx], 0xE0
	jne		not_ctrl_break
	add		bx, cx
	cmp		byte [es:bx], 0x46
	jne		not_ctrl_break
	add		bx, cx
	cmp		byte [es:bx], 0xE0
	jne		not_ctrl_break
	add		bx, cx
	cmp		byte [es:bx], 0xC6
	jne		not_ctrl_break
f12_break:	
	cmp		word [cs:scancode_processing], 0x00
	jne		not_ctrl_break
	xor		bx, bx
	mov		[es:scancodebuf-0x00], bx
	mov		[es:scancodebuf-0x02], bx
	mov		[es:scancodebuf-0x04], bx
	mov		[es:scancodebuf-0x06], bx
	mov		[es:scancodebuf-0x08], bx
	mov		[es:scancodebuf-0x0A], bx
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, ' '
	int 	0x10
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, '['
	int 	0x10
	mov		al, '^'
	int 	0x10
	mov		al, 'B'
	int 	0x10
	mov		al, 'r'
	int 	0x10
	mov		al, 'e'
	int 	0x10
	mov		al, 'a'
	int 	0x10
	mov		al, 'k'
	int 	0x10
	mov		al, ']'
	int 	0x10
	mov		word [cs:break_imm], 0x01;
	mov		word [cs:sector_to_load_ax], ax ;
	jmp		not_ctrl_break
	
	
f11_savescreen:
	
	push	ds
	mov		ax, 0xb800
	mov		ds, ax
	mov		ax, 0x9850
	mov		es, ax
	;ds:si => es:di
	
	xor		si, si
	xor		di, di
	mov		cx, 1000; 80*25*2
	rep		movsd
	pop		ds
	jmp		not_ctrl_break
	
f10_loadscreen:
	push	ds
	mov		ax, 0xb800
	mov		es, ax
	mov		ax, 0x9850
	mov		ds, ax
	;ds:si => es:di
	
	xor		si, si
	xor		di, di
	mov		cx, 1000; 80*25*2
	rep		movsd
	
	
	;mov		byte [es:0x0000],'H'
	;mov		byte [es:0x0001],0x07
	
	pop		ds
	jmp		not_ctrl_break
	
	
f9_showinfo:
	mov		ax, [cs:view_step_now]
;	call	putint
	inc		ax
	mov		[cs:view_step_now], ax
	dec		ax
	and		ax, [cs:view_delaycnt]
	mov		[cs:view_original], ax
	mov		ax, 0xB800
	mov		es, ax
	mov		ax, word [es:0x009C]
	mov		cx, word [es:0x009E]
	mov		word [cs:view_screenbuffer], ax
	mov		word [cs:view_screenbuffer+0x02], cx
	mov		byte [es:0x009C],'F'
	mov		byte [es:0x009D],0x4E ; 0x07; 01001110
	mov		cx, '0'
	add		cx, word [cs:now_screenid]
	mov		byte [es:0x009E],cl
	mov		byte [es:0x009F],0x4E
	mov		word [cs:view_length], 0x02
	jmp		not_ctrl_break
	
not_ctrl_break:
normal_keyboard_break:
	pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax
end_for_scancode:
	popf
	int		0xD5
	iret
set_keyboard_end:
	pop		es
;--------------------------------------------------
set_envbuf:
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
	add		ax, 0x18
	cli
	mov		[es:0x148], ax
	mov		[es:0x14A], cs
	sti
	jmp		near set_envbuf_end

	push	ax
	mov		ax, [ds:0xFFFE]
	mov		es, ax
	mov		[es:yotshell_sizeofenv], cx
	mov		[es:yotshell_ptrofenv], si
	
	pop		ax
	mov		di, yotshell_env_buf
	iret
set_envbuf_end:
	pop		es
;--------------------------------------------------	
save_envbuf: ; 0x53
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
	add		ax, 0x18
	cli
	mov		[es:0x14C], ax
	mov		[es:0x14E], cs
	sti
	jmp		near save_envbuf_end
	call	save_env_buf_intcall
	iret
save_envbuf_end:
	pop		es
;--------------------------------------------------	
load_envbuf: ; 0x54
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
	add		ax, 0x18
	cli
	mov		[es:0x150], ax
	mov		[es:0x152], cs
	sti
	jmp		near load_envbuf_end
	call	load_env_buf_intcall
	iret
load_envbuf_end:
	pop		es
;--------------------------------------------------	
load_shell_from_floppy:
;	xor		ax, ax 
;	xor		ah, ah
;	xor		dl, dl
;	int		0x13
	xor			bx, bx
	mov		[scancodebuf-0x00], bx
	mov		[scancodebuf-0x02], bx
	mov		[scancodebuf-0x04], bx
	mov		[scancodebuf-0x06], bx
	mov		[scancodebuf-0x08], bx
	mov		[scancodebuf-0x0A], bx
	mov		word [cs:break_imm], bx
	mov		word [cs:scancode_processing], 0x00
;continue_get_key_buf:
	;xor		ax, ax
	;inc		ax
	push	ax
	push	es
	mov		ax, 0x40
	mov		es, ax
	mov		ax, 0x30
	mov		[es:0x1A], ax
	mov		[es:0x1C], ax
	;mov		ax, [es:0x1A]
	;call	putint
	;mov		ax, [es:0x1C]
	;call	putint
	pop		es
	pop		ax
	
	;mov		ah, 0x01
	;int		16h
	;jz		continue_get_key_buf

	mov		ax, [shell_seg]
	mov		es, ax
	
	; start loading
	; mov		si, cx
	
	mov		ax, [sector_to_load]		; sector offset ; 10
	dec		ax
	mov		dx, ax
	and		ax, 0xFFF
	shr		dx, 0x0C
	inc		dx
	shl		dx, 0x03
	
	call	convchs
	cmp		ax, 0xFEFE; 0xFEFE & 0xFFF - 1
	je		load_nothing_img
	
;	pusha
;	call	putint
;	mov	ax, bx
;	call	putint
;	mov	ax, cx
;	call	putint
;	mov	ax, dx
;	call	putint
;	mov	ax, es
;	call	putint
;	mov	ax, 9999
;	call	putint
;	popa
	
	;pusha
	;call	putint
	;popa
	
	call	convchsformat
	xor			bx, bx
	;mov		bx, 0x0000		; es:bx
	;mov		al, 16
	;mov		bx, 0x0000
	;mov		ah, 0x02	; function: read disk sectors
	;mov		al, 16		; sector count
	;xor		dx, dx
	;mov		cx, [sector_to_load]		; sector offset ; 10
	
;	pusha
;	call	putint
;	mov	ax, bx
;	call	putint
;	mov	ax, cx
;	call	putint
;	mov	ax, dx
;	call	putint
;	mov	ax, es
;	call	putint
;	popa
	
	
;	cmp		cx, 0xF
;	jne		load_nothing_img

	
	int		0x13
	jc 		load_shell_failed
	
	
;	pusha
;	call	putint
;	mov		ax, cx
;	call	putint
;	mov		ax, dx
;	call	putint
;	popa
	
	;mov		ah, 0x02	; function: read disk sectors
	;mov		al, 16		; sector count
	;mov		dh, 0		; head
	;mov		dl, 0		; drive number
	;xor		dx, dx
	;mov		ch, 0		; track  ;0
	;mov		cl, [sector_to_load]		; sector offset ; 10
	
	int		0x13
	jc 		load_shell_failed
	jmp		load_disk_ok
	
load_nothing_img:
	jmp 		load_shell_failed
;	mov		byte [es:bx] , 0x33
;	mov		byte [es:bx+1],0xC0
;	mov		byte [es:bx+2],0xC3 ;RET
;	xor		ax, ax
;	mov		ax, 0x8050
;	mov		es, ax
;	mov		bx, 0x1200
;	mov		ah, 0x02	; function: read disk sectors
;	mov		al, 7		; sector count
;	mov		dh, 0		; head
;	mov		dl, 0		; drive number
;	mov		ch, 1		; track 
;	mov		cl, 1		; sector offset
	
;	int		0x13
;	jc 		load_shell_failed
;--------------------------------------------------
load_disk_ok:
view_loader_message:
	mov		ah, 0x0e
	;mov		al, ':'
	mov		bx, 0x0007
	;int		0x10
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
load_shell_failed:
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 'L'
	int		0x10
	mov		al, 'o'
	int		0x10
	mov		al, 'a'
	int		0x10
	mov		al, 'd'
	int		0x10
	mov		al, ' '
	int		0x10
	cmp		word [sector_to_load], 0x3021
	jne		load_prog_failed_str
	mov		al, 'S'
	int		0x10
	mov		al, 'h'
	int		0x10
	mov		al, 'e'
	int		0x10
	mov		al, 'l'
	int		0x10
	mov		al, 'l'
	int		0x10
	jmp		load_prog_failed_str_continue
load_prog_failed_str:
	pusha
	mov		ax, [sector_to_load]
	call	putint
	popa
load_prog_failed_str_continue:
	mov		al, ' '
	int		0x10
	mov		al, 'F'
	int		0x10
	mov		al, 'a'
	int		0x10
	mov		al, 'i'
	int		0x10
	mov		al, 'l'
	int		0x10
	mov		al, 'e'
	int		0x10
	mov		al, 'd'
	int		0x10
	mov		al, '.'
	int		0x10
	mov		al, ' '
	int		0x10
;	mov		al, 0x0D
;	int		0x10
;	mov		al, 0x0A
;	int		0x10
	cmp		word [sector_to_load], 0x3021
	je		shell_call_load_failed
	mov		word [sector_to_load], 0x3021
shell_call_load_failed:
	jmp		load_shell_from_floppy
;--------------------------------------------------
program_exit_no_to_save:
	mov		word [cs:scancode_processing], 0x01
	mov		sp, [cs:0x7FFE]
	mov		bx, cs
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	
	;cli
	;mov		si, 0x7FFE
	
	;sti
	mov		dx, ax

	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 0x0D
	int		0x10
	mov		al, 0x0A
	int		0x10
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
;	mov		al, ' '
;	int		0x10
	mov		ax, dx
	call	putint

	mov		word [sector_to_load], 0x3021
	jmp		load_shell_from_floppy
;--------------------------------------------------
program_exit:
;	mov		al, 'E'
;	mov		ah, 0x0E
;	int		0x10
;	mov		ax, cs
;	call 	putint
	mov		word [cs:scancode_processing], 0x01
	mov		sp, [cs:0x7FFE]
	mov		bx, cs
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	;mov		si, 0x7FFE
	;mov		sp, [si]
	mov		dx, ax
;	pop		dx
;	call	char_vga_setbios
	
;	mov		bx, 0x0007
;	mov		ah, 0x0E
;	mov		al, 0x0D
;	int		0x10
;	mov		al, 0x0A
;	int		0x10
	cmp		word [sector_to_load], 0x3021
	jne		not_shell_successful_call
	cmp		dx, 0xFFFF
	je		not_shell_successful_call
	cmp		dx, 0x0
	je		not_shell_successful_call

	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 'C'
	int		0x10
	mov		al, 'a'
	int		0x10
	mov		al, 'l'
	int		0x10
	mov		al, 'l'
	int		0x10
	mov		al, 'i'
	int		0x10
	mov		al, 'n'
	int		0x10
	mov		al, 'g'
	int		0x10
	mov		al, ' '
	int		0x10
	mov		al, 'P'
	int		0x10
	mov		al, 'r'
	int		0x10
	mov		al, 'o'
	int		0x10
	mov		al, 'g'
	int		0x10
	mov		al, 'r'
	int		0x10
	mov		al, 'a'
	int		0x10
	mov		al, 'm'
	int		0x10
	mov		al, ' '
	int		0x10
	mov		ax, dx
	call	putint
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, '.'
	int		0x10
	mov		al, '.'
	int		0x10
	mov		al, '.'
	int		0x10
	mov		ax, dx
	jmp		not_to_need_show_exitcode
not_shell_successful_call:
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, 0x0D
	int		0x10
	mov		al, 0x0A
	int		0x10
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
	;mov		bx, 0x0007
	;mov		ah, 0x0E
	;mov		al, 'E'
	;int		0x10
	;mov		ax, sp
	;call	putint
	;int 	0x10
	;db		0xEB, 0xFE
	;jmp		_main
	;jmp		view_loader_message
not_to_need_show_exitcode:
	

	cmp		word [sector_to_load], 0x3021
	je		shell_call
	mov		ax, 0x3021
shell_call:
	cmp		ax, 0xFFFF
	jne		shell_call_continue
	mov		ax, 0x3021
shell_call_continue:
	cmp		ax, 0x0
	jne		shell_call_continue2
	mov		ax, 0x3021
shell_call_continue2:
	cmp		word [sector_to_load], 0x3021
	jne		not_to_save
	call	save_env_buf
not_to_save:
	mov		[sector_to_load], ax
	jmp		load_shell_from_floppy
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
	
	;mov		ah, 0x0e
	;mov		bx, 0x0007
	;mov		al, ','
	;int		0x10
	
	popa
	ret
;--------------------------------------------------
very_very_far_func:
;	call	char_vga_savebios
;	push	dx
;	call	load_env_buf

	mov		si, 0x7FFE
	mov		[si], sp
	
	mov		bx, [shell_seg]
	cli
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	mov		bx, 0xFFFF
	mov		si, bx
	mov		dx, 0xFFF8
	mov		sp, dx
	mov		bp, dx
	sti
	mov		[si-0x0001], cs
	add		ax, 0x0A
	mov		[si-0x0003], ax
	mov		dl, 0xFA
	mov		[si-0x0007], dx
	mov		dl, 0x5A
	mov		[si-0x0005], dl
	mov		dl, 0xCB
	mov		[si-0x0004], dl
	db		0xEA
	dw		0x0000
shell_seg:
	dw		0x8050
	;jmp		0x8050:0x0000
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
putcharhex:
	push	dx
	push	ax
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
	pop		ax
	pop		dx
	ret
fourbit2hex:		; al=argument=result
	cmp		al, 10
	jae		fourbit2hex_alpha
	add		al, '0'
	ret
fourbit2hex_alpha:
	add		al, 'A' - 10
	ret	

load_env_buf_intcall:
	push	di
	push	ds
	push	es
	push	cx
	push	si
	pushf
	cld
	push	ds
	pop		es
	push	cs
	pop		ds
	;mov		ax, cs;[ds:0xFFFE]
	;mov		ds, ax
	mov		cx, [cs:yotshell_sizeofenv]
	cmp		cx, 0xBAAD
	je		load_env_buf_unseted
	xor		ax, ax
	cmp		[cs:yotshell_envseted], ax
	je		load_env_buf_unseted
	mov		ax, cx
	;pusha
	;call	putint
	;popa
	mov		di, [cs:yotshell_ptrofenv]
	mov		si, yotshell_env_buf
	rep		movsb
	
	jmp		load_env_buf_step2
load_env_buf_unseted:
	xor		ax, ax
load_env_buf_step2:
	popf
	pop		si	
	pop		cx
	pop		es
	pop		ds
	pop		di
	ret

save_env_buf:
	push	di
	push	ds
	push	cx
	push	ax
	push	si
	pushf
	push	ds
	pop		es
	cld
	mov		cl, 0x01
	mov		[yotshell_envseted], cl
	mov		cx, [yotshell_sizeofenv]
	cmp		cx, 0xBAAD
	je		save_env_buf_unseted
	mov		si, [yotshell_ptrofenv]
	mov		di, yotshell_env_buf
	mov		ax, [shell_seg]
	mov		ds, ax
	rep		movsb
save_env_buf_unseted:
	popf
	pop		si
	pop		ax
	pop		cx
	pop		ds
	pop		di
	ret
	
save_env_buf_intcall:
	push	di
	push	es
	push	cx
	push	ax
	push	si
	pushf
	cld
	mov		ax, [ds:0xFFFE]
	mov		es, ax
	mov		cl, 0x01
	mov		[es:yotshell_envseted], cl
	mov		cx, [es:yotshell_sizeofenv]
	cmp		cx, 0xBAAD
	je		save_env_buf_unseted_intcall
save_env_buf_unseted_intcall:
	mov		si, [es:yotshell_ptrofenv]
	mov		di, yotshell_env_buf
	rep		movsb
	popf
	pop		si
	pop		ax
	pop		cx
	pop		es
	pop		di
	ret

convchs: ; LBA=AX; CHS = CBA
	pushf
;	call	putint
	cmp		ax, 32; 0x3021
	je		vaild_LBA
	cmp		ax, word [chs_minium]
	jb		invaild_LBA
	cmp		ax, word [chs_maxium]
	ja		invaild_LBA
	jmp		vaild_LBA
invaild_LBA:
	push	bx
	mov		bx, 0x0007
	mov		ah, 0x0e
	mov		al, 'O'
	int		0x10
	mov		al, 'v'
	int		0x10
	mov		al, 'e'
	int		0x10
	mov		al, 'r'
	int		0x10
	mov		al, 'f'
	int		0x10
	mov		al, 'l'
	int		0x10
	mov		al, 'o'
	int		0x10
	mov		al, 'w'
	int		0x10
	mov		al, '.'
	int		0x10
	mov		al, '.'
	int		0x10
	mov		al, '.'
	int		0x10
	pop		bx
	mov		ax, 0xFEFE
	popf
	ret
;	mov		ax, 9; 0x3021
vaild_LBA:
	push	dx
	xor		dx, dx
	mov		bx, [chs_sectors_num]
	div		bx
	inc		dx
	push	dx
	xor		dx, dx
	mov		bx, [chs_heads_num]
	div		bx
	mov		cx, ax
	mov		bx, dx
	pop		ax
	pop		dx
	popf
	ret
	
convchsformat: ; c:h:s = cx:bx:ax 
	;mov		[convchsformat_buf_c], cx
	;mov		[convchsformat_buf_h], bx
	;mov		[convchsformat_buf_s], ax
	;mov		[convchsformat_buf_num], dx
	
	xchg	ch, cl
	shl		cl, 0x06
	add		cl, al
	mov		al, dl
	mov		ah, 0x02
	xor		dl, dl
	mov		dh, bl

	;mov		ah, [convchsformat_buf_num]
	
	ret

;convchsformat_buf_c: dw 0x0
;convchsformat_buf_h: dw 0x0
;convchsformat_buf_s: dw 0x0
;convchsformat_buf_num: dw 0x0

;global var
putintbuf: times 5 db 0
break_imm: dw 0x00
scancodebufp: times 7 dw 0 
scancodebuf: dw 0
scancode_int_buf: db 0x0
chs_sectors_num: dw 18
chs_heads_num: dw 0x2
chs_minium: dw 32
chs_maxium: dw 2880;2880
view_delaycnt: dw 15; 2^7
view_step_now: dw 0x0
view_original: dw 0x0; 2^7
view_screenbuffer: times 16 dw 0
view_length: dw 0
now_screenid:	dw 0x1
scancode_processing:	dw 0x1 ; disable

local_var_start:
;-----------------------------------:
;local_var
sector_to_load: dw 0x3021
sector_to_load_ax: dw 0xAAAA
yotshell_sizeofenv: dw 0xBAAD ; BAAD => unset
yotshell_ptrofenv: dw 0xBAAD
yotshell_envseted: db 0x00
yotshell_env_buf: times 512 dw 0 
;-------------------------------------
local_var_end:
local_var_size: dw 0
	
;multiprocess_position: dw 0x8050

