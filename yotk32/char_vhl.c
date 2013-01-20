/* char_vhl = char VGA high level function */

#include "yotk32.h"

extern int char_vga_cursor_x;
extern int char_vga_cursor_y;

void chv_init_cursor(void){
	int curpos = char_vga_get_cursor();
	char_vga_cursor_x = CHAR_VGA_GETX(curpos);
	char_vga_cursor_y = CHAR_VGA_GETY(curpos);
}

void chv_get_cursor(xycoord)
	XYCOORD* xycoord;
{
	chv_init_cursor();
	xycoord->x = char_vga_cursor_x;
	xycoord->y = char_vga_cursor_y;
}

void chv_set_cursor(xycoord)
	const XYCOORD* xycoord;
{
	char_vga_cursor_x = xycoord->x;
	char_vga_cursor_y = xycoord->y;
	char_vga_set_cursor(
		CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y));
}

void chv_set_cursor_direct(x, y)
	int x;
	int y;
{
	char_vga_cursor_x = x;
	char_vga_cursor_y = y;
	char_vga_set_cursor(
		CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y));
}

void chv_sync_cursor(void){
	char_vga_set_cursor(
		CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y));
}

void chv_reset_cursor(void){
	chv_set_cursor_direct(0, 0);
}

void chv_movenext_cursor(void){
	if(++char_vga_cursor_x >= CHAR_VGA_SCREENX){
		char_vga_cursor_x -= CHAR_VGA_SCREENX;
		char_vga_cursor_y++;
	}
	if(char_vga_cursor_y >= CHAR_VGA_SCREENY){
		char_vga_cursor_y = CHAR_VGA_SCREENY;
		chv_scroll(1);
	}
}

void chv_moveprev_cursor(void){
	if(--char_vga_cursor_x < 0){
		char_vga_cursor_x += CHAR_VGA_SCREENX;
		char_vga_cursor_y--;
	}
	if(char_vga_cursor_y < 0){
		char_vga_cursor_y = 0;
	}
}

void chv_move_cursor(count)
	int count;
{
	int n;
	n = CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y) + count;
	char_vga_cursor_x = CHAR_VGA_GETX(n);
	char_vga_cursor_y = CHAR_VGA_GETY(n);
	if(char_vga_cursor_x > CHAR_VGA_SCREENX){
		char_vga_cursor_x = CHAR_VGA_SCREENX - 1;
	}else if(char_vga_cursor_x < 0){
		char_vga_cursor_x = 0;
	}
	if(char_vga_cursor_y > CHAR_VGA_SCREENY){
		char_vga_cursor_y = CHAR_VGA_SCREENY - 1;
	}else if(char_vga_cursor_y < 0){
		char_vga_cursor_y = 0;
	}
}

void chv_next_line(void){
	if(++char_vga_cursor_y >= CHAR_VGA_SCREENY){
		char_vga_cursor_y--;
		chv_scroll(1);
		char_vga_cursor_y++;
	}
	char_vga_cursor_x = 0;
}

void chv_putchar(c)
	int c;
{
	chv_memwrite(
		CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y) * 2, c);
	chv_movenext_cursor();
}

void chv_putchar_color(c, color)
	int c;
	int color;
{
	int pos = CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y) * 2;
	chv_memwrite(pos++, c);
	chv_memwrite(pos, color);
	chv_movenext_cursor();
}

void chv_backspace(void){
	chv_moveprev_cursor();
	chv_memwrite(
		CHAR_VGA_POSITION(char_vga_cursor_x, char_vga_cursor_y) * 2, ' ');
}

void chv_clear(void){
	int i;
	XYCOORD xycoord;
	chv_memwrite(0, 'A');
	for(i=0; i< CHAR_VGA_MMIOSIZE; ){
		chv_memwrite(i++, ' ');
		chv_memwrite(i++, CHV_COLORPAIR(
			CHV_COLOR_LIGHT_GRAY, CHV_COLOR_BLACK));
	}
}

void chv_scroll(line)
	int line;
{
	int c, i;
	int src, dest;
	if(line > 0){
		src = line * CHAR_VGA_SCREENX * 2;
		for(dest = 0; dest < CHAR_VGA_MMIOSIZE && src < CHAR_VGA_MMIOSIZE; 
			dest++, src++){
			c = chv_memread(src);
			chv_memwrite(dest, c);
		}
		for(; dest < CHAR_VGA_MMIOSIZE; ){
			chv_memwrite(dest++, ' ');
			chv_memwrite(dest++, CHV_COLORPAIR(
				CHV_COLOR_LIGHT_GRAY, CHV_COLOR_BLACK));
		}
		char_vga_cursor_y -= line; 
		if(char_vga_cursor_y < 0){
			char_vga_cursor_y = 0;
			chv_sync_cursor();
		}
	}
}

