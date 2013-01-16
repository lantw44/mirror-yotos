#ifndef YOT_OS_LIBC16
#define YOT_OS_LIBC16

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

#define exit(globalvar) \
	asm "mov sp, bp"; \
	asm "mov ax, [_" #globalvar "]" ; \
	asm "pop bp"; \
	asm "retf"

/* str_out.s */
void putint(unsigned short);         /* 以 10 進位顯示一個 word (unsigned) */
void putcharhex(char);      /* 以 16 進位顯示一個 byte */
void putstr(const char*);   /* 顯示一個字串，'\0' 是結束 */

/* char_in.s */
#define GETCH_SCANCODE(code16) (((code16) & 0xff00) >> 8)
#define GETCH_ASCII(code16)    ((code16) & 0x00ff)
int getch(void);

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
void chv_putchar(int);
void chv_putchar_color(int, int);
void chv_backspace(void);
void chv_clear(void);
void chv_scroll(int);
char chv_memread(int);
void chv_memwrite(int, char);

#define chv_screen_write_char(position,character) \
	chv_memwrite(((position)*2), (character))
#define chv_screen_write_color(position,color) \
	chv_memwrite(((position)*2+1), (color))

int  char_vga_get_cursor(void);
void char_vga_set_cursor(int);
void char_vga_frombios(void);
void char_vga_tobios(void);

/* keyboard scan codes */
#define KEYDOWN_SCANCODE_ESC          0x01
#define KEYDOWN_SCANCODE_BS           0x0e
#define KEYDOWN_SCANCODE_TAB          0x0f
#define KEYDOWN_SCANCODE_ENTER        0x1c
#define KEYDOWN_SCANCODE_CTRL         0x1d
#define KEYDOWN_SCANCODE_LEFT_SHIFT   0x2a
#define KEYDOWN_SCANCODE_RIGHT_SHIFT  0x36
#define KEYDOWN_SCANCODE_PRINT_SCREEN 0x37
#define KEYDOWN_SCANCODE_ALT          0x38
#define KEYDOWN_SCANCODE_SPACE        0x39
#define KEYDOWN_SCANCODE_CAPS_LOCK    0x3a
#define KEYDOWN_SCANCODE_FUNCTION(n)  (0x3a+(n))  /* F1 ~ F10，其他不適用 */
#define KEYDOWN_SCANCODE_NUM_LOCK     0x45
#define KEYDOWN_SCANCODE_SCROLL_LOCK  0x46
#define KEYDOWN_SCANCODE_HOME         0x47
#define KEYDOWN_SCANCODE_UP           0x48
#define KEYDOWN_SCANCODE_PAGE_UP      0x49
#define KEYDOWN_SCANCODE_LEFT         0x4b
#define KEYDOWN_SCANCODE_RIGHT        0x4d
#define KEYDOWN_SCANCODE_END          0x4f
#define KEYDOWN_SCANCODE_DOWN         0x50
#define KEYDOWN_SCANCODE_PAGE_DOWN    0x51
#define KEYDOWN_SCANCODE_INSERT       0x52
#define KEYDOWN_SCANCODE_DELETE       0x53

/* keypad */
#define KEYDOWN_SCANCODE_KEYPAD_ENTER 0x1c
#define KEYDOWN_SCANCODE_KEYPAD_SLASH 0x35
#define KEYDOWN_SCANCODE_KEYPAD_STAR  0x37
#define KEYDOWN_SCANCODE_KEYPAD_7     0x47
#define KEYDOWN_SCANCODE_KEYPAD_8     0x48
#define KEYDOWN_SCANCODE_KEYPAD_9     0x49
#define KEYDOWN_SCANCODE_KEYPAD_MINUS 0x4a
#define KEYDOWN_SCANCODE_KEYPAD_4     0x4b
#define KEYDOWN_SCANCODE_KEYPAD_5     0x4c
#define KEYDOWN_SCANCODE_KEYPAD_6     0x4d
#define KEYDOWN_SCANCODE_KEYPAD_ADD   0x4e
#define KEYDOWN_SCANCODE_KEYPAD_1     0x4f
#define KEYDOWN_SCANCODE_KEYPAD_2     0x50
#define KEYDOWN_SCANCODE_KEYPAD_3     0x51
#define KEYDOWN_SCANCODE_KEYPAD_0     0x52
#define KEYDOWN_SCANCODE_KEYPAD_DOT   0x53

/* str_in.c */
int getstr(char*, int, int);
/* 讀入一行的函式
 * ARG1 = 要存到哪裡
 * ARG2 = 最多可以讀多長（'\0' 不計入，但要自行保留空間）
 * RVAL = 實際讀了幾個字 */

int yotrl(char*, const char*, int, int);
/* 同上，但是是進階版 */


/* strbasic.c */
int strcmp(const char*, const char*);
int strtos(const char*, unsigned int*);

#endif

