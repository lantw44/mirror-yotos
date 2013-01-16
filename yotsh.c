#include <yotlibc.h>
#define CMDMAX 256

#define YOTSH_ENABLED(n)   ((ctrlflag)&(n))
#define YOTSH_AUTOCOPY	   0x0001
#define YOTSH_COUNTER      0x0002

int main(void){
	int cmdcount;
	int ctrlflag;
	char cmdline[CMDMAX];
	char argcopy[CMDMAX];
	char *cp1, *cp2;
	bool end;
	unsigned out;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;
	XYCOORD screenxy;

	cmdline[0] = '\0';
	ctrlflag = YOTSH_COUNTER;

	putstr("\r\nYOT OS shell [Real mode]\r\n\r\n");

	for(cmdcount=1; ; cmdcount++){
		if(YOTSH_ENABLED(YOTSH_COUNTER)){
			putint(cmdcount);
			putstr(":");
		}else{
			putstr("<");
		}

		putstr("yotsh> ");

		if(YOTSH_ENABLED(YOTSH_AUTOCOPY)){
			yotrl(cmdline, cmdline, CMDMAX - 1, 
				CHV_COLORPAIR(CHV_COLOR_LIGHT_CYAN, CHV_COLOR_BLACK));
		}else{
			yotrl(cmdline, NULL, CMDMAX - 1,
				CHV_COLORPAIR(CHV_COLOR_LIGHT_RED, CHV_COLOR_BLACK));
		}

		for(cp1=cmdline, cp2=argcopy; *cp1 != ' '&& *cp1 != '\0'; cp1++, cp2++){
			*cp2 = *cp1;
		}

		end = ((*cp1 == '\0') ? true : false);
		*cp2 = '\0';

		if(!strcmp(argcopy, "set")){
			cp2 = cmdline + 3;
			if(!end){
				cp2++;
			}
			if((*cp2 == '\0' || *cp2 == '?') || !strcmp(cp2, "help")){
				putstr("YOTSH function list:"
					"\r\n autocopy   "
					"Automatically copy last command to input buffer"
					"\r\n counter    "
					"Enable counter in command prompt"
					"\r\n");
			}else if(!strcmp(cp2, "autocopy")){
				ctrlflag |= YOTSH_AUTOCOPY;
			}else if(!strcmp(cp2, "counter")){
				ctrlflag |= YOTSH_COUNTER;
			}else{
				putstr("yotsh: set: invalid function name `");
				putstr(cp2);
				putstr("\'\r\n");
			}
		}else if(!strcmp(argcopy, "unset")){
			cp2 = cmdline + 5;
			if(!end){
				cp2++;
			}
			if((*cp2 == '\0' || *cp2 == '?') || !strcmp(cp2, "help")){
				putstr("Please type `set help\' to get function list\r\n");
			}else if(!strcmp(cp2, "autocopy")){
				ctrlflag &= ~(YOTSH_AUTOCOPY);
			}else if(!strcmp(cp2, "counter")){
				ctrlflag &= ~(YOTSH_COUNTER);
			}else{
				putstr("yotsh: unset: invalid function name `");
				putstr(cp2);
				putstr("\'\r\n");
			}
		}else if(!strcmp(argcopy, "read")){
			cp2 = cmdline + 4;
			if(!end){
				cp2++;
			}
			if(strtos(cp2, &out)){
				cp1 = out;
				out = *cp1 & 0x00ff;
				putstr("decimal=");
				putint(out);
				putstr(", hexadecimal=");
				putcharhex(out);
				putstr("\r\n");
			}else{
				putstr("yotsh: read: invalid address `");
				putstr(cp2);
				putstr("\'\r\n");
			}
		}else if(!strcmp(argcopy, "halt") || 
				!strcmp(argcopy, "poweroff") || 
				!strcmp(argcopy, "shutdown")){
			asm "int 0x50";
		}else if(!strcmp(argcopy, "reboot")){
			cp1 = 0;
			asm "int 0x51";
		}else if(*argcopy != '\0'){
			putstr("yotsh: invalid command `");
			putstr(argcopy);
			putstr("\'\r\n");
		}else{
			cmdcount--;
		}
	}
	return 0;
}
