#include <yotlibc.h>

short rval = 8;
short abc[100];
int main(void){
	XYCOORD xys;
	short k;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;
	int i;
//	xys.x = 1;
//	xys.y = 1;
//	chv_set_cursor(&xys);
//	char_vga_tobios();
//	putint(char_vga_cursor_x);
//	putint(char_vga_cursor_y);
	chv_init_cursor();
	chv_memwrite(5, 4);
	xys.y = 23;
	xys.x = 4;
	chv_set_cursor(&xys);
	putint(char_vga_cursor_y);
	for(i=0; i<9; i++){
		chv_putchar('F');
	}
	chv_sync_cursor();
	yotrl(abc, "", 99);
	putstr(abc);
//	chv_putchar_color('A', CHV_COLORPAIR(CHV_COLOR_GREEN, CHV_COLOR_GRAY));
//	chv_backspace();
//	chv_scroll(25);
//	chv_clear();
//	chv_reset_cursor();
//	chv_sync_cursor();
//	chv_putchar('A');
//	char_vga_tobios();
//	putint(22);
//	putint(chv_memread(5));
//	putstr("PPP");
	//putstr("KKK:");
	/*while(1){
		int a = getch();
		a = GETCH_SCANCODE(a);
		putcharhex(a);
	}
	putint(getstr(abc, 10));
	putstr(abc);*/
	return 0xFFFD;
}
