#include "yotlibc.h"

int getstr(dest, maxlen)
	char* dest;
	int maxlen;
{
	int c, cascii, cscan;
	int i = 0, j;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;

	chv_init_cursor();

	for(;;){
		c = getch();
		cascii = GETCH_ASCII(c);
		cscan = GETCH_SCANCODE(c);
		if(cascii >= 32 && cascii < 128){
			if(i < maxlen){
				dest[i++] = cascii;
				chv_putchar(cascii);
				chv_sync_cursor();
			}
		}else{
			switch(cscan){
				case KEYDOWN_SCANCODE_ENTER:
					dest[i++] = '\0';
					char_vga_cursor_y++;
					char_vga_cursor_x = 0;
					chv_sync_cursor();
					char_vga_tobios();
					return i;
				case KEYDOWN_SCANCODE_BS:
					if(i <= 0){
						continue;
					}
					dest[i--] = '\0';
					chv_backspace();
					chv_sync_cursor();
					break;
				case KEYDOWN_SCANCODE_ESC:
					chv_move_cursor(-i);
					for(j=0; j<i; j++){
						chv_putchar(' ');
					}
					chv_move_cursor(-i);
					chv_sync_cursor();
					i = 0, dest[0] = '\0';
					break;

			}
		}
	}
	return 0;
}

int yotrl(dest, init, maxlen)
	char* dest;
	char* init;
	int maxlen;
{
	int c, cascii, cscan;
	int pos = 0, nowlen = 0, i;
	char* ip;
	int blank;
	char prechar;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;
	XYCOORD xy;

	chv_init_cursor();

	if(init != NULL){
		for(i=0; i<maxlen && init[i] != '\0'; i++){
			dest[i] = init[i];
		}
		dest[i] = '\0';
		pos = i, nowlen = i;
		for(ip = dest; *ip != '\0'; ip++){
			chv_putchar(*ip);
		}
	}

	chv_sync_cursor();

	for(;;){
		c = getch();
		cascii = GETCH_ASCII(c);
		cscan = GETCH_SCANCODE(c);
		/* 判斷規則：正常輸入 -> scan code ->  ASCII code 控制鍵 */
		if(cascii >= 32 && cascii < 128){
			if(nowlen + 1 <= maxlen){
				if(pos == nowlen){
					dest[pos++] = cascii;
					nowlen++;
					chv_putchar(cascii);
					chv_sync_cursor();
				}else{
					xy.x = char_vga_cursor_x;
					xy.y = char_vga_cursor_y;
					for(i=nowlen; i>pos; i--){
						dest[i] = dest[i-1];
					}
					dest[pos] = cascii;
					chv_putchar(cascii);
					nowlen++, pos++;
					for(i=pos; i<nowlen; i++){
						chv_putchar(dest[i]);
					}
					char_vga_cursor_x = xy.x;
					char_vga_cursor_y = xy.y;
					chv_movenext_cursor();
					chv_sync_cursor();
				}
			}
		}else{
			switch(cscan){
				case KEYDOWN_SCANCODE_ENTER:
					dest[nowlen++] = '\0';
					char_vga_cursor_y++;
					char_vga_cursor_x = 0;
					chv_sync_cursor();
					char_vga_tobios();
					return nowlen;
				case KEYDOWN_SCANCODE_LEFT:
					if(pos > 0){
						pos--;
						chv_moveprev_cursor();
						chv_sync_cursor();
					}
					continue;
				case KEYDOWN_SCANCODE_RIGHT:
					if(pos < nowlen){
						pos++;
						chv_movenext_cursor();
						chv_sync_cursor();
					}
					continue;
				case KEYDOWN_SCANCODE_BS:
					if(pos <= 0){
						continue;
					}
					if(pos == nowlen){
						dest[pos--] = '\0';
						nowlen--;
						chv_backspace();
						chv_sync_cursor();
					}else{
						chv_moveprev_cursor();
						xy.x = char_vga_cursor_x;
						xy.y = char_vga_cursor_y;
						for(i=pos; i<nowlen; i++){
							dest[i-1] = dest[i];
						}
						pos--, nowlen--;
						for(i=pos; i<nowlen; i++){
							chv_putchar(dest[i]);
						}
						chv_putchar(' ');
						char_vga_cursor_x = xy.x;
						char_vga_cursor_y = xy.y;
						chv_sync_cursor();
					}
					continue;
				case KEYDOWN_SCANCODE_DELETE:
					if(pos >= nowlen){
						continue;
					}
					xy.x = char_vga_cursor_x;
					xy.y = char_vga_cursor_y;
					for(i=pos; i<nowlen; i++){
						dest[i] = dest[i+1];
					}
					nowlen--;
					for(i=pos; i<nowlen; i++){
						chv_putchar(dest[i]);
					}
					chv_putchar(' ');
					char_vga_cursor_x = xy.x;
					char_vga_cursor_y = xy.y;
					chv_sync_cursor();
					continue;
				case KEYDOWN_SCANCODE_HOME:
					cascii = 1;  /* 與 Ctrl+A 相同*/
					break;
				case KEYDOWN_SCANCODE_END:
					cascii = 5;  /* 與 Ctrl+E 相同 */
					break;
				case KEYDOWN_SCANCODE_ESC:
					cascii = 3;  /* 與 Ctrl+C 相同 */
					break;
			}

			switch(cascii){
				case 1: /* Ctrl+A */
					chv_move_cursor(-pos);
					chv_sync_cursor();
					pos = 0;
					break;
				case 3: /* Ctrl+C */
					chv_move_cursor(-pos);
					for(i=0; i<nowlen; i++){
						chv_putchar(' ');
					}
					chv_move_cursor(-nowlen);
					chv_sync_cursor();
					nowlen = 0, pos = 0;
					break;
				case 5: /* Ctrl+E */
					chv_move_cursor(nowlen - pos);
					chv_sync_cursor();
					pos = nowlen;
					break;
				case 11: /* Ctrl+K */
					blank = nowlen - pos;
					xy.x = char_vga_cursor_x;
					xy.y = char_vga_cursor_y;
					for(i=0; i<blank; i++){
						chv_putchar(' ');
					}
					nowlen = pos;
					char_vga_cursor_x = xy.x;
					char_vga_cursor_y = xy.y;
					chv_sync_cursor();
					break;
				case 21: /* Ctrl+U */
					blank = pos;
					for(i=pos; i<nowlen; i++){
						dest[i-blank] = dest[i];
					}
					chv_move_cursor(-pos);
					xy.x = char_vga_cursor_x;
					xy.y = char_vga_cursor_y;
					pos = 0;
					nowlen -= blank;
					for(i=0; i<nowlen; i++){
						chv_putchar(dest[i]);
					}
					for(i=0; i<blank; i++){
						chv_putchar(' ');
					}
					char_vga_cursor_x = xy.x;
					char_vga_cursor_y = xy.y;
					chv_sync_cursor();
					break;
				case 23: /* Ctrl+W */
					if(pos == 0){
						break;
					}
					for(i=pos-1; i>=0 && dest[i] == ' '; i--);
					for(; i>=0 && dest[i] != ' '; i--);
					i++;
					blank = pos - i;
					if(i < blank){
						i = blank;
					}
					for(i=pos; i<nowlen; i++){
						dest[i-blank] = dest[i];
					}
					pos -= blank;
					nowlen -= blank;
					chv_move_cursor(-blank);
					xy.x = char_vga_cursor_x;
					xy.y = char_vga_cursor_y;
					for(i=pos; i<nowlen; i++){
						chv_putchar(dest[i]);
					}
					for(i=0; i<blank; i++){
						chv_putchar(' ');
					}
					char_vga_cursor_x = xy.x;
					char_vga_cursor_y = xy.y;
					chv_sync_cursor();
					break;
			}
		}
	}
	return 0;
}
