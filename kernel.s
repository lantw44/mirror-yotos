	global	_main

_main:
	mov		ax, [now_screenid]
	mov		cx, 0x1000
	mul		cx
	sub		ax, 0x1000
	add		ax, 0x0050
	mov		[cs:shell_seg], ax
	
	mov		sp, 0xF6F6
	mov		word [local_var_size],local_var_end
	sub		word [local_var_size],local_var_start
	mov		ax, word [local_var_size]
	cmp		ax, 6144
	je		show_6144
	call	putint
	
show_6144:
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
	mov		al, 0x0E
	mov		dx, 0xCF9
	out		dx, al
	mov		al, 0x06
	out		dx, al
	mov		al, 0xFE
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
	
	
;------------------------------------------------------
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
	jmp	cencel_10101092
 	push	ax
 	push	es
check_kb_buf:
	xor		ax, ax

	push	ax
 	pop		es
 	mov		ax, [es:0x41C]
	sub		ax, [es:0x41A]
	cmp		ax, 24
	ja		clear_kb_buf
	jmp		no_clear_kb_buf
clear_kb_buf:
	mov		ax, [es:0x41A]
	add		ax, 2
	cmp		ax, 0x3C
	jbe		gosll
	mov		ax, 0x1E
gosll:
	mov		[es:0x41C], ax
	xor		ah, ah
	int		0x16
	jmp		check_kb_buf
no_clear_kb_buf:
	pop		es
    pop		ax
cencel_10101092:

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
	cmp		byte [es:bx], 0x44
	je		f10_showdatetime
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x43
	je		f9_showinfo
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x3B
	je		f1_switch_to_screen_1
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x3C
	je		f2_switch_to_screen_2
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x3D
	je		f3_switch_to_screen_3
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x3E
	je		f4_switch_to_screen_4
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x3F
	je		f5_switch_to_screen_5
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x40
	je		f6_switch_to_screen_6
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x41
	je		f7_switch_to_screen_7
	
	lea		bx, [es:scancodebufp+0x0F]
	cmp		byte [es:bx], 0x42
	je		f8_switch_to_screen_8
	
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

	mov		word [cs:sector_to_load_ax], ax 
	
	xor		bx, bx
	mov		[es:scancodebuf-0x00], bx
	mov		[es:scancodebuf-0x02], bx
	mov		[es:scancodebuf-0x04], bx
	mov		[es:scancodebuf-0x06], bx
	mov		[es:scancodebuf-0x08], bx
	mov		[es:scancodebuf-0x0A], bx
	
	cmp		word [cs:scancode_processing], 0x00
	jne		not_ctrl_break
	
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

	mov		word [cs:break_imm], 0x01
	mov		word [cs:scancode_processing], 0x01
	jmp		not_ctrl_break
	
f9_showinfo:
	mov		ax, [cs:view_step_now]
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
	
f10_showdatetime:
	
	mov		ax, [cs:view_step_now]
	inc		ax
	mov		[cs:view_step_now], ax
	dec		ax
	and		ax, [cs:view_delaycnt]
	mov		[cs:view_original], ax
	mov		ax, 0xB800
	mov		es, ax
	mov		bp, 0x74
	
	cld
	
	mov		cx, 160
	sub		cx, bp
	mov		word [cs:view_start], bp
	mov		word [cs:view_length], cx
	
	push	es
	push	ds
	push	di
	push	si
	
	push	es
	pop		ds
	
	
	
	push	cs
	pop		es
	
	mov		si, bp
	mov		di, view_screenbuffer
	
	rep		movsb
	
	pop		si
	pop		di
	pop		ds
	pop		es

	mov		ah, 0x04
	int		0x1A
	mov		al, ch
	xor		ah, ah
	
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp

	mov		ah, 0x04
	int		0x1A
	mov		al, cl
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],'/'
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		ah, 0x04
	int		0x1A
	mov		al, dh
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],'/'
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		al, dl
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],' '
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		ah, 0x02
	int		0x1A
	mov		al, ch
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],':'
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		al, cl
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],':'
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		al, dh
	xor		ah, ah
	call	putint_td
	
	mov		byte [es:bp],dl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],dh
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],' '
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		byte [es:bp],'P'
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	mov		cx, '0'
	add		cx, word [cs:now_screenid]
	
	mov		byte [es:bp],cl
	inc		bp
	mov		byte [es:bp],0x4E
	inc		bp
	
	
	jmp		not_ctrl_break
	
f1_switch_to_screen_1:
	mov		word [cs:to_screenid], 0x1
	cmp		word [cs:now_screenid], 0x1
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x180
	jmp		switch_to_screen_all
	
f2_switch_to_screen_2:
	mov		word [cs:to_screenid], 0x2
	cmp		word [cs:now_screenid], 0x2
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x300
	jmp		switch_to_screen_all
	
f3_switch_to_screen_3:
	mov		word [cs:to_screenid], 0x3
	cmp		word [cs:now_screenid],0x3
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x480
	jmp		switch_to_screen_all
	
f4_switch_to_screen_4:
	mov		word [cs:to_screenid], 0x4
	cmp		word [cs:now_screenid],0x4
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x600
	jmp		switch_to_screen_all
	
f5_switch_to_screen_5:
	mov		word [cs:to_screenid], 0x5
	cmp		word [cs:now_screenid],0x5
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x780
	jmp		switch_to_screen_all
	
f6_switch_to_screen_6:
	mov		word [cs:to_screenid], 0x6
	cmp		word [cs:now_screenid],0x6
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0x900
	jmp		switch_to_screen_all
	
f7_switch_to_screen_7:
	mov		word [cs:to_screenid], 0x7
	cmp		word [cs:now_screenid],0x7
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0xA80
	jmp		switch_to_screen_all
	
f8_switch_to_screen_8:
	mov		word [cs:to_screenid], 0x8
	cmp		word [cs:now_screenid],0x8
	je		not_ctrl_break
	mov		word [cs:to_screenid_seg], 0xC00
	jmp		switch_to_screen_all

switch_to_screen_all:

	xor		bx, bx
	mov		[es:scancodebuf-0x00], bx
	mov		[es:scancodebuf-0x02], bx
	mov		[es:scancodebuf-0x04], bx
	mov		[es:scancodebuf-0x06], bx
	mov		[es:scancodebuf-0x08], bx
	mov		[es:scancodebuf-0x0A], bx
	
	cmp		word [cs:switch_imm], 0x00
	jne		quit_switch_to_screen_all
	
	mov		bx, 0x0007
	mov		ah, 0x0E
	mov		al, ' '
	int 	0x10

	mov		word [cs:switch_imm], 0x01
	jmp		not_ctrl_break

quit_switch_to_screen_all:
not_ctrl_break:
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
	
;--------------


 	push	ax
 	push	es
 
recheck_kb_buf:
	xor		ax, ax

	push	ax
	pop		es
	mov		ax, [es:0x41C]
	sub		ax, [es:0x41A]
	cmp		ax, 24
 	ja		reclear_kb_buf
 	jmp		no_reclear_kb_buf
reclear_kb_buf:
	xor		ah, ah
	int		0x16
	mov		ax, [es:0x41A]
	add		ax, 2
	cmp		ax, 0x3C
	jbe		gosllww
	mov		ax, 0x1E
gosllww:
	mov		[es:0x41C], ax
	
	jmp		recheck_kb_buf
no_reclear_kb_buf:
	pop		es
   pop		ax
   
cencel_10101093:
    
;--------------------------------------------------
update_timer:
	inc		word [cs:view_step_now]
;--------------------------------------------------

break_imm_function:
	cli
	cmp		word [cs:break_imm],0x00
	je		quit_break_imm_function
	
	mov			word [cs:break_imm],0x00
	mov			word [cs:scancode_processing], 0x02
	mov			ax, [cs:sector_to_load_ax];
	cmp			word [cs:sector_to_load], 0x3021 ;
	jne			break_imm_not_shell_load_break
	mov			ax, 0xFFFF
	jmp			break_imm_shell_load_break
	
break_imm_not_shell_load_break:
	mov			word [cs:sector_to_load], 0x3021
	sti
	popf
	jmp			program_exit_no_to_save
	
break_imm_shell_load_break:
	sti
	popf
	jmp			program_exit
quit_break_imm_function:
	popf
	pushf


;--------------------------------------------------
view_screen_timer:
	cmp		word [cs:view_length], 0x00
	je		quit2_view_screen_timer
	cli
	push	ax
	push	cx
	
	mov		ax, [cs:view_step_now]
	and		ax, [cs:view_delaycnt]
	cmp		ax, [cs:view_original]
	jne		quit_view_screen_timer
	
	push	es
	mov		ax, 0xB800
	mov		es, ax
	
	cld
	
	mov		cx, [cs:view_length]
	
	push	es
	push	ds
	push	di
	push	si
	
	push	cs
	pop		ds
	
	nop 
	nop
	mov		di, [cs:view_start]
	mov		si, view_screenbuffer
	
	rep		movsb
	
	pop		si
	pop		di
	pop		ds
	pop		es


	mov		word [cs:view_length], 0x00
	
	
	pop		es

quit_view_screen_timer:
	pop		cx
	pop		ax
quit2_view_screen_timer:
;--------------------------------------------------
switch_function:
	cmp		word [cs:switch_imm],0x00
	je		quit_switch_function
	mov		word [cs:switch_imm],0x00
	cli
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	ss
	push	sp
	push	bp
	push	si
	push	di
	nop
	nop
	nop
	nop
	
store_data_to_local:

save_reg_to_now:
	mov		ax, ss
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, sp
	mov		di, register_buf
	mov		cx, 15
	cld
	rep		movsw

	mov		[cs:register_buf+6], sp

save_screen_to_now:
	mov		ax, 0xb800
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, screen_data_buf
	mov		cx, 1000
	cld
	rep		movsd

save_bda_to_now:
	mov		ax, 0x40
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, bios_bda_databuf
	mov		cx, 64
	cld
	rep		movsd
	
save_ebda_to_now:
	mov		ax, 0x9FC0
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, bios_ebda_databuf
	mov		cx, 256
	cld
	rep		movsd

save_now_to_archive:	
	mov		ax, cs
	mov		ds, ax
	mov		ax, [cs:now_screenid]
	mov		cx, 0x180
	mul		cx
	mov		cx, cs ; 6kb
	add		ax, cx
	mov		es, ax
	mov		si, local_var_start; now
	mov		di, local_var_start; 1
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
load_new_to_now:	
	mov		ax, cs
	mov		es, ax
	mov		ax, [cs:to_screenid]
	mov		cx, 0x180
	mul		cx
	mov		cx, cs ; 6kb
	add		ax, cx
	mov		ds, ax
	mov		di, local_var_start; now
	mov		si, local_var_start; 1
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
load_now_to_screen:
	mov		ax, 0xb800
	mov		es, ax
	mov		ax, cs
	mov		ds, ax
	mov		di, 0x0
	mov		si, screen_data_buf
	mov		cx, 1000
	cld
	rep		movsd
load_now_to_bda:
	mov		ax, 0x40
	mov		es, ax
	mov		ax, cs
	mov		ds, ax
	mov		di, 0x0
	mov		si, bios_bda_databuf
	mov		cx, 64
	cld
	rep		movsd
	
load_now_to_ebda:
	mov		ax, 0x9FC0
	mov		es, ax
	mov		ax, cs
	mov		ds, ax	
	mov		di, 0x0
	mov		si, bios_ebda_databuf
	mov		cx, 256
	cld
	rep		movsd

load_now_prework:
	mov		sp, [cs:register_buf+6]
	mov		ss, [cs:register_buf+8]
	
load_now_to_reg:
	mov		ax, ss
	mov		es, ax
	mov		ax, cs
	mov		ds, ax
	mov		di, sp
	mov		si, register_buf
	mov		cx, 15
	cld
	rep		movsw
	
	
	
	pop		di
	pop		si
	pop		bp
	pop		ax
	pop		ax
	pop		ds
	
	
	
	
	
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
	
	pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	
	mov		ax, [cs:view_step_now]
	inc		ax
	mov		[cs:view_step_now], ax
	dec		ax
	and		ax, [cs:view_delaycnt]
	mov		[cs:view_original], ax
	mov		ax, 0xB800
	mov		es, ax
	cmp		word [cs:view_length], 0x00
	jne		not_need_savscr
	mov		ax, word [es:0x009C]
	mov		cx, word [es:0x009E]
	mov		word [cs:view_start], 0x9C
	mov		word [cs:view_screenbuffer], ax
	mov		word [cs:view_screenbuffer+0x02], cx
	mov		word [cs:view_length], 0x04
not_need_savscr:
	mov		cx, '0'
	add		cx, word [cs:now_screenid]
	mov		byte [es:0x009C],cl
	mov		byte [es:0x009D],0x4E
	mov		cx, '0'
	add		cx, word [cs:to_screenid]
	mov		byte [es:0x009E],cl
	mov		byte [es:0x009F],0x4E
	
	
	mov		ax, [cs:to_screenid]
	mov		cx, 0x1000
	mul		cx
	sub		ax, 0x1000
	add		ax, 0x0050
	mov		[cs:shell_seg], ax
	mov		ax, [cs:to_screenid]
	mov		[cs:now_screenid], ax

	pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax	

check_is_it_not_loadshell:
	cmp		word [cs:register_buf+24], start_point
	nop
	nop
	nop
	jne		quit_switch_function

	mov		sp, [cs:initialize_sp]
	mov		ax, start_point
	mov		bx, cs
	mov		es, bx
	mov		ss, bx
	mov		ds, bx
	push		ax

	ret
	rdtsc
	

quit_switch_function:
;--------------------------------------------------
timer_ret:
	
	
	
	popf
	iret

set_timer_end:
	pop		es
;--------------------------------------------------

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
save_envbuf:
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
load_envbuf:
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

jmp envbuf_functions_end

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
	mov		cx, [cs:yotshell_sizeofenv]
	cmp		cx, 0xBAAD
	je		load_env_buf_unseted
	xor		ax, ax
	cmp		[cs:yotshell_envseted], ax
	je		load_env_buf_unseted
	mov		ax, cx
	mov		di, [cs:yotshell_ptrofenv]
	mov		si, yotshell_env_buf
	cld
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
	cld
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
	cld
	rep		movsb
	popf
	pop		si
	pop		ax
	pop		cx
	pop		es
	pop		di
	ret
envbuf_functions_end:

	mov		word [initialize_sp], sp
	pushf
	push	cs
	mov		ax, start_point
	push	ax
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	ss
	push	sp
	push	bp
	push	si
	push	di
	
	push	es

	
	mov		ax, 0x0050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF	
loop0050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop0050
	
	mov		ax, 0x1050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF	
loop1050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop1050
	
	mov		ax, 0x2050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop2050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop2050
	
	mov		ax, 0x3050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop3050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop3050
	
	mov		ax, 0x4050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop4050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop4050
	
	mov		ax, 0x5050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop5050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop5050
	
	mov		ax, 0x6050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop6050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop6050
	
	mov		ax, 0x7050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop7050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop7050
	
	mov		ax, 0x8050
	push	ax
	pop		es
	mov		bx, 0xFFFF
	mov		cx, 0xFFFF
loop8050:
	mov		byte [es:bx], 0x0
	dec		bx
	loop	loop8050
	



	
	pop		es
		
init_save_reg_to_now:
	mov		ax, ss
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, sp
	mov		di, register_buf
	mov		cx, 15
	cld
	rep		movsw
	



	
	add		sp, 30
	sub		word [cs:register_buf+6], 8


	
init_save_screen_to_now:
	mov		ax, 0xb800
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, screen_data_buf
	mov		cx, 1000
	cld
	rep		movsd

init_save_bda_to_now:
	mov		ax, 0x40
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, bios_bda_databuf
	mov		cx, 64
	cld
	rep		movsd
	
init_save_ebda_to_now:
	mov		ax, 0x9FC0
	mov		ds, ax
	mov		ax, cs
	mov		es, ax
	mov		si, 0x0
	mov		di, bios_ebda_databuf
	mov		cx, 256
	cld
	rep		movsd
	
to_archive_1:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x180 
	mov		es, ax
	mov		si, local_var_start
	mov		di, local_var_start
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
	
to_archive_2:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x300 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
to_archive_3:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x480 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
to_archive_4:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x600 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
to_archive_5:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x780 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
to_archive_6:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0x900 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
to_archive_7:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0xA80 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	;mov		word [es:register_buf+2], 0x6050
	
to_archive_8:	
	mov		ax, cs
	mov		ds, ax
	add		ax, 0xC00 ; 6kb
	mov		es, ax
	mov		si, local_var_start;
	mov		di, local_var_start;
	mov		cx, [cs:local_var_size]
	cld
	rep		movsb
	
;--------------------------------------------------
start_point:
	
	nop	
load_shell_from_floppy:
	sti
	xor			bx, bx
	mov		[scancodebuf-0x00], bx
	mov		[scancodebuf-0x02], bx
	mov		[scancodebuf-0x04], bx
	mov		[scancodebuf-0x06], bx
	mov		[scancodebuf-0x08], bx
	mov		[scancodebuf-0x0A], bx
	mov		word [cs:break_imm], bx
	
	L1:	mov ah,11h 	; check keyboard buffer
	int 16h 	; any key pressed?
	jz  noKey 	; no: exit now
	mov ah,10h 	; yes: remove from buffer
	int 16h
	jmp L1 	; no: check buffer again

noKey: 	; no key pressed
	or  al,1 	; clear zero flag

	mov		ax, [shell_seg]
	mov		es, ax
	
	mov		ax, [sector_to_load]		; sector offset ; 10
	dec		ax
	mov		dx, ax
	and		ax, 0xFFF
	shr		dx, 0x0C
	inc		dx
	shl		dx, 0x03

	mov		cx,0xFFFF
	a0fffloop:
		dec		cx
	loopnz	a0fffloop
	mov		cx,0xFFFF
	a0fffloop1:
		dec		cx
	
	loopnz	a0fffloop1
	mov		cx,0xFFFF
	a0fffloop2:
		dec		cx
	
	loopnz	a0fffloop2
	mov		cx,0xFFFF
	a0fffloop3:
		dec		cx
	
	loopnz	a0fffloop3
	mov		cx,0xFFFF
	a0fffloop4:
		dec		cx
	
	loopnz	a0fffloop4
	mov		cx,0xFFFF
	a0fffloop5:
		dec		cx
	
	loopnz	a0fffloop5
	
	call	convchs
	cmp		ax, 0xFEFE; 0xFEFE & 0xFFF - 1
	je		load_nothing_img
	
	call	convchsformat
	xor			bx, bx
	xor		si, si
	xor		di, di
	int		0x13
	jmp		load_disk_ok
	
load_nothing_img:
	jmp 		load_shell_failed
;--------------------------------------------------
load_disk_ok:
view_loader_message:
	mov		ah, 0x0e
	mov		bx, 0x0007
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
	call	putint
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
	cmp		word [sector_to_load], 0x3021
	je		shell_call_load_failed
	mov		word [sector_to_load], 0x3021
shell_call_load_failed:
	jmp		load_shell_from_floppy
;--------------------------------------------------
very_very_far_func:

	mov		si, 0xF6F6
	mov		[si], sp
	
	mov		bx, [shell_seg]
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
	mov		word [cs:scancode_processing], 0x00
	mov		word [cs:ok_for_once_shell], 0x01
	
	db		0xEA
	dw		0x0000
shell_seg:
	dw		0x0050

;--------------------------------------------------
program_exit_no_to_save:
	mov		word [cs:scancode_processing], 0x02
	mov		sp, [cs:0xF6F6]
	mov		bx, cs
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	
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
	mov		ax, dx
	call	putint

	mov		word [sector_to_load], 0x3021
	jmp		load_shell_from_floppy
;--------------------------------------------------
program_exit:

	mov		word [cs:scancode_processing], 0x02
	mov		sp, [cs:0xF6F6]
	mov		bx, cs
	mov		ds, bx
	mov		es, bx
	mov		ss, bx
	mov		dx, ax
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
	
	mov		ah, 0x0e
	mov		bx, 0x0007
	
	popa
	ret
;--------------------------------------------------
putint_td:				; ax=argument
	push	cx
	mov		cl, al
	push	bx
	push	ax
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, cl
	and		al, 0xf0
	shr		al, 4
	call	fourbit2hex
	mov		dl, al
	mov		al, cl
	and 	al, 0x0f
	call	fourbit2hex
	mov		dh, al
	pop		ax
	pop		bx
	pop		cx
	ret
;--------------------------------------------------
putint_ptr:				; ax=argument
	pusha
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, '['
	int		0x10
	popa
	pusha
	mov		di, 0	; dest index
	mov		si, 10	; divisor, ax=dividend
	putint_divloop_ptr:
		mov		dx, 0	; clear upper bits
		div		si
		add		dx, '0'
		mov		byte [putintbuf+di], dl
		inc		di
		cmp		ax, 0
		ja		putint_divloop_ptr

	mov		ah, 0x0e
	mov		bx, 0x0007
	
	putint_print_ptr:
		dec		di
		mov		al, byte [putintbuf+di]
		int		0x10
		cmp		di, 0
		ja		putint_print_ptr
	
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, ']'
	int		0x10
	
	popa
	ret
;--------------------------------------------------
putint_sp:				; ax=argument
	pusha
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, '{'
	int		0x10
	popa
	pusha
	putint_divloop_sp:
		mov		dx, 0	; clear upper bits
		div		si
		add		dx, '0'
		mov		byte [putintbuf+di], dl
		inc		di
		cmp		ax, 0
		ja		putint_divloop_sp

	mov		ah, 0x0e
	mov		bx, 0x0007
	
	putint_print_sp:
		dec		di
		mov		al, byte [putintbuf+di]
		int		0x10
		cmp		di, 0
		ja		putint_print_sp
	
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, '}'
	int		0x10
	
	popa
	ret
;--------------------------------------------------
putint_bp:				; ax=argument
	pusha
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, '@'
	int		0x10
	popa
	pusha
	putint_divloop_bp:
		mov		dx, 0	; clear upper bits
		div		si
		add		dx, '0'
		mov		byte [putintbuf+di], dl
		inc		di
		cmp		ax, 0
		ja		putint_divloop_bp

	mov		ah, 0x0e
	mov		bx, 0x0007
	
	putint_print_bp:
		dec		di
		mov		al, byte [putintbuf+di]
		int		0x10
		cmp		di, 0
		ja		putint_print_bp
	
	mov		ah, 0x0e
	mov		bx, 0x0007
	mov		al, '!'
	int		0x10
	
	popa
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

convchs: ; LBA=AX; CHS = CBA
	pushf
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
	xchg	ch, cl
	shl		cl, 0x06
	add		cl, al
	mov		al, dl
	mov		ah, 0x02
	xor		dl, dl
	mov		dh, bl

	ret

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
view_screenbuffer: times 256 dw 0
view_length: dw 0
view_start: dw 0
now_screenid:	dw 0x1
now_screen_seg:	dw 0x1
to_screenid:	dw 0x1
to_screenid_seg:	dw 0x1
scancode_processing:	dw 0x2 ; disable
initialize_sp: dw 0
ok_for_once_shell: dw 0
switch_imm: dw 0 

local_var_size: dw 0

local_var_start:
;-----------------------------------:
;local_var
data_tag_start: db 0xBA, 0xAD, 0xBa, 0xAD
register_buf: times 40 db 0 					; 0x0028
sector_to_load: dw 0x3021						; 0x0002
sector_to_load_ax: dw 0x3021					; 0x0002
yotshell_sizeofenv: dw 0xBAAD ; BAAD => unset	; 0x0002
yotshell_ptrofenv: dw 0xBAAD					; 0x0002
yotshell_envseted: db 0x00						; 0x0001
yotshell_env_buf: times 256 db 0 				; 0x0100
bios_bda_databuf: times 256 db 0 				; 0x0100
bios_ebda_databuf: times 1024 db 0 				; 0x0400
screen_data_buf: times 4000 db 0 				; 0x0FA0
data_tag_end: db 0xF0, 0x0D, 0xF0, 0x0D
res:	times 0x227 db 0 
;-------------------------------------
local_var_end:
