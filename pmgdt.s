global _main
global _pm_bootstrap
global gdt_start
global gdt_null
global gdt_code
global gdt_data
global gdt_user_code
global gdt_user_data
global gdt_end
global gdt_descriptor

[bits 16]

_main:
_pm_bootstrap:
	mov		dx, msg_title
	call	putstr
	mov		dx, msg_ldgdt
	call	putstr

	cli
	lgdt	[gdt_descriptor]

	in		al, 0x92
	or		al, 2
	out		0x92, al

	mov		eax, cr0
	or		eax, 0x1
	mov		cr0, eax

	jmp		dword CODE_SEGMENT:pmkernel

msg_title: db 13, 10, 'YOTOS protected mode loader', 13, 10, 0
msg_ldgdt: db 'Loading Global Descriptor Table (GDT)... ', 0

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



; GDT entry


gdt_start:

gdt_null:	; null descriptor
	dd	0x00
	dd	0x00

gdt_code:	; code segment descriptor
	dw	0xffff		; segment limit (bits 0-15)
	dw	0x0			; base (bits 0-15)
	db	0x0			; base (bits 16-23)

	db	10011010b	; (present) 1,
					; (privilege) 00,
					; (descriptor type) 1,
					; type = 
					; (code) 1, 
					; (conforming) 0, 
					; (readable) 1,
					; (accessed) 0

	db	11001111b	; (granularity) 1,
					; (32-bit default) 1,
					; (64-bit segment) 0, 
					; (AVL) 0,
					; segment limit (bits 16-19)
	
	db	0x0			; base (bits 24-31)

gdt_data:	; data segment descriptor
	dw	0xffff		; segment limit (bits 0-15)
	dw	0x0			; base (bits 0-15)
	db	0x0			; base (bits 16-23)

	db	10010010b	; (present) 1,
					; (privilege) 00,
					; (descriptor type) 1,
					; type = 
					; (code) 0, 
					; (expand down) 0, 
					; (writable) 1,
					; (accessed) 0

	db	11001111b	; (granularity) 1,
					; (32-bit default) 1,
					; (64-bit segment) 0, 
					; (AVL) 0,
					; segment limit (bits 16-19)
	
	db	0x0			; base (bits 24-31)

gdt_user_code:	; user mode code segment descriptor
	dw	0xffff		
	dw	0x0			
	db	0x0			
	db	11111010b	
	db	11001111b	
	db	0x0			

gdt_user_data:	; user mode data segment descriptor
	dw	0xffff
	dw	0x0
	db	0x0
	db	11110010b
	db	11001111b  
	db	0x0  

gdt_end:

gdt_descriptor:
	dw	gdt_end - gdt_start - 1
	dd	load_offset + gdt_start

CODE_SEGMENT	equ		gdt_code - gdt_start
DATA_SEGMENT	equ		gdt_data - gdt_start


