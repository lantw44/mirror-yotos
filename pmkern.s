extern _putstr
extern _chv_next_line
extern _chv_init_cursor
extern _chv_putchar
extern _chv_sync_cursor
extern _chv_next_line
extern _int_isr_handler
extern _int_irq_handler

global _start
global _pm_init
global idt_start
global idt_end
global idt_descriptor

CODE_SEGMENT		equ		0x08 ; gdt_code - gdt_start
DATA_SEGMENT		equ		0x10 ; gdt_data - gdt_start
USER_CODE_SEGMENT	equ		0x18 ; gdt_user_code - gdt_start
USER_DATA_SEGMENT	equ		0x20 ; gdt_user_data - gdt_start

[bits 32]

%macro ISR_NOERRCODE 1
	global _int_isr_%1
	_int_isr_%1:
		cli
		push	byte 0
		push	byte %1
		jmp		_int_isr_common
%endmacro

%macro ISR_ERRCODE 1
	global _int_isr_%1
	_int_isr_%1:
		cli
		push	byte %1
		jmp		_int_isr_common
%endmacro

%macro IDT_ISR_ENTRY 1
	mov		eax, _int_isr_%1
	mov		word [ebx], ax
	mov		word [ebx+2], CODE_SEGMENT
	mov		byte [ebx+4], 0
	mov		byte [ebx+5], 0x80 | 14
	mov		eax, _int_isr_%1
	shr		eax, 16
	mov		word [ebx+6], ax
	add		ebx, 8
%endmacro

%macro IRQ 2
	global _int_irq_%1
	_int_irq_%1:
		cli
		push	byte 0
		push	byte %2
		jmp		_int_irq_common
%endmacro

%macro IDT_IRQ_ENTRY 1
	mov		eax, _int_irq_%1
	mov		word [ebx], ax
	mov		word [ebx+2], CODE_SEGMENT
	mov		byte [ebx+4], 0
	mov		byte [ebx+5], 0x80 | 14
	mov		eax, _int_irq_%1
	shr		eax, 16
	mov		word [ebx+6], ax
	add		ebx, 8
%endmacro


_start:
_pm_init:
	mov		ax, DATA_SEGMENT
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax

	mov		ebp, 0x90500
	mov		esp, ebp

	call	_chv_init_cursor

	call	_chv_next_line
	push	msg_ldidt
	call	_putstr
	add		esp, 4
	call	_chv_sync_cursor

	; Create IDT entry
	mov		ebx, idt_start

%assign intcount 0
%rep 32
	IDT_ISR_ENTRY intcount
%assign intcount intcount+1
%endrep

%assign intcount 0
%rep 16
	IDT_IRQ_ENTRY intcount
%assign intcount intcount+1
%endrep

	; Load IDT descriptor
	lidt	[idt_descriptor]

	; ========== IDT OK ==========

	call	_chv_next_line
	push	msg_remap_irq
	call	_putstr
	add		esp, 4
	call	_chv_sync_cursor

	sub		esp, 2

	; Save masks
	mov		dx, 0x21	; PIC1
	in		al, dx
	mov		byte [esp], al

	mov		dx, 0xA1	; PIC2
	in		al, dx
	mov		byte [esp+1], al

	; Initialize two PICs
	mov		dx, 0x20	; PIC1
	mov		al, 0x11	
	out		dx, al

	mov		dx, 0xA0	; PIC2
	mov		al, 0x11
	out		dx, al

	; Set vector offset
	mov		dx, 0x21	; PIC1
	mov		al, 0x20	; IRQ 0 -> INT 0x20
	out		dx, al

	mov		dx, 0xA1	; PIC2
	mov		al, 0x28	; IRQ 8 -> INT 0x28
	out		dx, al

	; Master/Slave PIC
	mov		dx, 0x21	; PIC1
	mov		al, 0x04	; there is a slave PIC at IRQ2 (0000 0100)
	out		dx, al

	mov		dx, 0xA1	; PIC2
	mov		al, 0x02	; tell Slave PIC its cascade identity (0000 0010)
	out		dx, al

	; Set 8086/88 mode
	mov		dx, 0x21	; PIC1
	mov		al, 0x01	
	out		dx, al

	mov		dx, 0xA1	; PIC2
	mov		al, 0x01
	out		dx, al

	; Restore mask
	mov		dx, 0x21	; PIC1
	mov		al, byte [esp]
	out		dx, al

	mov		dx, 0xA1	; PIC2
	mov		al, byte [esp+1]
	out		dx, al

	add		esp, 2

	; ========== IRQ remap OK ==========

	sti

	call	_chv_next_line
	call	_chv_next_line
	push	msg_pmkernel
	call	_putstr
	add		esp, 4
	call	_chv_next_line
	call	_chv_next_line
	call	_chv_sync_cursor

sleep_forever:
	call	_chv_next_line
	push	msg_sleep_forever
	call	_putstr
	add		esp, 4
	call	_chv_sync_cursor
	
	; Set timer
	mov		dx, 0x43	; timer command port
	mov		al, 0x36
	out		dx, al

	mov		ax, 11932
	mov		dx, 0x40

	out		dx, al
	mov		ah, al
	out		dx, al

jump_forever:
	hlt
	hlt
	hlt
	hlt
	hlt
	jmp		jump_forever


msg_ldidt: db 'Loading Interrupt Descriptor Table (IDT)... ', 0
msg_remap_irq: db 'Remapping Interrupt requests (IRQ)... ', 0
msg_pmkernel: db 'OK, YOT OS protected mode kernel is started', 0
msg_sleep_forever: db 'No instruction available - sleep forever', 0

idt_start:
	times 256 dq 0
idt_end:

idt_descriptor:
	dw	idt_end - idt_start - 1
	dd	idt_start

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE 8
ISR_NOERRCODE 9
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47


_int_isr_common:
	pushad

	mov		ax, ds
	push	eax

	mov		ax, DATA_SEGMENT
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax

	call	_int_isr_handler

	pop		eax
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax

	popad

	add		esp, 8
	sti
	iret

_int_irq_common:
	pushad

	mov		ax, ds
	push	eax

	mov		ax, DATA_SEGMENT
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax

	call	_int_irq_handler

	pop		eax
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		fs, ax

	popad
	add		esp, 8
	sti
	iret
