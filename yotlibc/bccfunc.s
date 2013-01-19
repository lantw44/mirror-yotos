; 專門給 bcc 用的，我不知道為什麼它會缺基本功能
global _env_load
global _env_save
global _env_def
global isru
global isr
global isl
global islu
global imul_
global imul_u
global imodu
global idiv_u
global imod
global imodu

idiv_:
	cwd
	idiv	bx
	ret
	

idiv_u:
	xor	dx,dx
	div	bx
	ret
	

imod:
	cwd
	idiv	bx
	mov	ax,dx	
	ret
	

imodu:
	xor	dx,dx
	div	bx
	mov	ax,dx
	ret
	

imul_:
imul_u:
	imul	bx
	ret
	
	
isl:
islu:
	mov	cl,bl
	shl	ax,cl
	ret


isr:
	mov	cl,bl
	sar	ax,cl
	ret
	

isru:
	mov	cl,bl
	shr	ax,cl
	ret
	

_env_def:
	push	bp
	mov		bp, sp
	push	cx
	push	si
	mov		cx, [bp+6]
	mov		si, [bp+4]
	int		0x52
	pop		si
	pop		cx
	mov		sp, bp
	pop		bp
	ret
	

_env_save:
	int		0x53
	ret
	

_env_load:
	int		0x54
	ret

