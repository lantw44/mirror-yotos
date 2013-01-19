#include <yotlibc.h>
/*
short rval = 8;
short abc[100];*/
int main()
{
	putstr("i am reader.c");
	return 0xF00D;
/*	XYCOORD xys;
	short k;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;
	int i;

	chv_init_cursor();
	chv_memwrite(5,4);
	xys.y = 23;
	xys.x = 4;
	chv_set_cursor(&xys);
	putint(char_vga_cursor_y);
	for(i=0; i<9; i++){
		chv_putchar('F');
	}
	chv_sync_cursor();
	yotrl(abc,"",99);
	putstr(abc);
	chv_putchar(' ');
	
	while(1){
		int a = getch();
		a = GETCH_SCANCODE(a);
		putcharhex(a);
	}
	putint(getstr(abc,10));
	putstr(abc);

	return 0xF00D;*/
}
