#include <yotk32.h>

typedef struct registers
{
	long ds;
	long edi, esi, ebp, esp, ebx, edx, ecx, eax;
	long int_no, err_code;
	long eip, cs, eflags, useresp, ss;
} registers_t; 


void int_isr_handler(registers_t regs){
	chv_putchar(regs.int_no);
	chv_sync_cursor();
}

void timer_sleep_msg(void){
	static int count = 0;
	count++;
	if(count % 100 == 0){
		putstr("...");
		putint(count / 100);
		chv_sync_cursor();
	}
}

void int_irq_handler(registers_t regs){
	asm(".intel_syntax noprefix\n");

	if(regs.int_no > 31 + 8){  /* Send reset signal to slave PIC (PIC2) */
		asm volatile(
			"mov dx, 0xA0\n"
			"mov al, 0x20\n"
			"out dx, al");
	}

	/* Send reset signal to master PIC (PIC1) */
	asm volatile(
		"mov dx, 0x20\n"
		"mov al, 0x20\n"
		"out dx, al");

	if(regs.int_no == 32){ /* IRQ0 == Timer */
		timer_sleep_msg();
	}
}
