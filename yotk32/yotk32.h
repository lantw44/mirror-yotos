#ifndef YOT_OS_KERNEL32_LIB
#define YOT_OS_KERNEL32_LIB

#ifndef NULL
#define NULL ((char*)0)
#endif

#ifndef EOF
#define EOF (-1)
#endif

#ifndef bool
#define bool char
#endif

#ifndef true
#define true 1
#endif

#ifndef false
#define false 0
#endif

/* str_out.s */
void putint(unsigned long);         /* 以 10 進位顯示一個 word (unsigned) */
void putcharhex(char);      /* 以 16 進位顯示一個 byte */
void putstr(const char*);   /* 顯示一個字串，'\0' 是結束 */

/* char_vga.s + char_vhl.c */
#define CHAR_VGA_POSITION(x,y) (((y)*80)+(x))
#define CHAR_VGA_GETX(n)       ((n)%80)
#define CHAR_VGA_GETY(n)       ((n)/80)
#define CHAR_VGA_SCREENX       80
#define CHAR_VGA_SCREENY       25
#define CHAR_VGA_SCREENSIZE    ((CHAR_VGA_SCREENX)*(CHAR_VGA_SCREENY))
#define CHAR_VGA_MMIOSIZE      ((CHAR_VGA_SCREENSIZE)*2)

#define CHV_COLORPAIR(fg,bg)     ((fg) | ((bg) << 4))
#define CHV_COLOR_BLACK          0
#define CHV_COLOR_BLUE           1
#define CHV_COLOR_GREEN          2
#define CHV_COLOR_CYAN           3
#define CHV_COLOR_RED            4
#define CHV_COLOR_MAGENTA        5
#define CHV_COLOR_BROWN          6
#define CHV_COLOR_LIGHT_GRAY     7
#define CHV_COLOR_GRAY           8
#define CHV_COLOR_LIGHT_BLUE     9
#define CHV_COLOR_LIGHT_GREEN    10
#define CHV_COLOR_LIGHT_CYAN     11
#define CHV_COLOR_LIGHT_RED      12
#define CHV_COLOR_LIGHT_MAGNETA  13
#define CHV_COLOR_LIGHT_BROWN    14
#define CHV_COLOR_WHITE          15

typedef struct char_vga_position{
	int x, y;
} XYCOORD;

void chv_init_cursor(void);
void chv_sync_cursor(void);
void chv_reset_cursor(void);
void chv_get_cursor(XYCOORD*);
void chv_set_cursor(const XYCOORD*);
void chv_set_cursor_direct(int, int);
void chv_movenext_cursor(void);
void chv_moveprev_cursor(void);
void chv_move_cursor(int);
void chv_next_line(void);
void chv_putchar(int);
void chv_putchar_color(int, int);
void chv_backspace(void);
void chv_clear(void);
void chv_scroll(int);

#define chv_memread(position) \
	(*((char*)((0xb8000)+(position))))
#define chv_memwrite(position,byte) \
	((*((char*)((0xb8000)+(position)))) = (byte))

#define chv_screen_write_char(position,character) \
	chv_memwrite(((position)*2), (character))
#define chv_screen_write_color(position,color) \
	chv_memwrite(((position)*2+1), (color))

int  char_vga_get_cursor(void);
void char_vga_set_cursor(int);

/* strbasic.c */
int strcmp(const char*, const char*);
int strtos(const char*, unsigned int*);

#endif

