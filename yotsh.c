#include <yotlibc.h>
#define CMDMAX 256

#define YOTSH_ENABLED(n)   ((ctrlflag)&(n))
#define YOTSH_AUTOCOPY	   0x0001
#define YOTSH_COUNTER      0x0002
#define YOTSH_VERBOSE      0x0004
int main(){
	/*---------------------*/
	int cmdcount;
	int ctrlflag;
	/*---------------------*/
	
	char cmdline[CMDMAX];
	char argcopy[CMDMAX];
	char *cp1, *cp2;
	bool end;
	unsigned out, loadaddr;
	extern int char_vga_cursor_x;
	extern int char_vga_cursor_y;
	XYCOORD screenxy;
	/*env_def(&ENV_END-sizeof(int),&ENV_START-&ENV_END-sizeof(int));*/
	env_def(&ctrlflag, 2*2);
	if(!env_load()){
		ctrlflag = YOTSH_COUNTER;
		cmdcount = 0;
		putstr("YOT OS shell [Real mode]\r\n\r\n");
	}
	cmdline[0] = '\0';
	while(++cmdcount){
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

		if(YOTSH_ENABLED(YOTSH_VERBOSE)){
			putstr("+ ");
			putstr(cmdline);
			putstr("\r\n");
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
			for(; *cp2 == ' '; cp2++);
			if((*cp2 == '\0' || *cp2 == '?') || !strcmp(cp2, "help")){
				putstr("YOTSH function list:"
					"\r\n autocopy   "
					"Automatically copy last command to input buffer"
					"\r\n counter    "
					"Enable counter in command prompt"
					"\r\n verbose    "
					"Print the input line as they are read"
					"\r\n");
			}else if(!strcmp(cp2, "autocopy")){
				ctrlflag |= YOTSH_AUTOCOPY;
			}else if(!strcmp(cp2, "counter")){
				ctrlflag |= YOTSH_COUNTER;
			}else if(!strcmp(cp2, "verbose")){
				ctrlflag |= YOTSH_VERBOSE;
			}else{
				putstr("yotsh: set: invalid function name `");
				putstr(cp2);
				putstr("\'\r\n");
				putstr("Type `set help\' for more information.\r\n");
			}
		}else if(!strcmp(argcopy, "unset")){
			cp2 = cmdline + 5;
			if(!end){
				cp2++;
			}
			for(; *cp2 == ' '; cp2++);
			if((*cp2 == '\0' || *cp2 == '?') || !strcmp(cp2, "help")){
				putstr("Please type `set help\' to get function list\r\n");
			}else if(!strcmp(cp2, "autocopy")){
				ctrlflag &= ~(YOTSH_AUTOCOPY);
			}else if(!strcmp(cp2, "counter")){
				ctrlflag &= ~(YOTSH_COUNTER);
			}else if(!strcmp(cp2, "verbose")){
				ctrlflag &= ~(YOTSH_VERBOSE);
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
			if(*cp2 == '\0'){
				putstr("yotsh: read: too few argument\r\n");
				continue;
			}
			for(; *cp2 == ' '; cp2++);
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
		}else if(!strcmp(argcopy, "tinyload") ||
				!strcmp(argcopy, "easyload")){
			cp2 = cmdline + 8;
			if(!end){
				cp2++;
			}
			for(; *cp2 == ' '; cp2++);
			if(*cp2 == '\0'){
				putstr("yotsh: tinyload: too few argument\r\n");
				continue;
			}
			if(strtos(cp2, &out)){
				out &= 0x0fff;
				out |= 0x1000;
				return out;
			}else{
				putstr("yotsh: read: invalid address `");
				putstr(cp2);
				putstr("\'\r\n");
			}
		}else if(!strcmp(argcopy, "load")){
			cp2 = cmdline + 4;
			if(!end){
				cp2++;
			}
			for(; *cp2 == ' '; cp2++);
			if(*cp2 == '\0'){
				putstr("yotsh: load: two argument required\r\n");
				continue;
			}
			loadaddr = 0;
			for(cp1=cp2; *cp1 != ' ' && *cp1 != '\0'; cp1++);
			for(; *cp1 == ' '; cp1++);

			if(*cp1 == '\0'){
				putstr("yotsh: load: two argument required\r\n");
				continue;
			}
			for(; *cp1 == ' '; cp1++);
			*(cp1 - 1) = '\0';
			if(strtos(cp2, &out)){
				out &= 0x0fff;
				loadaddr |= out;
			}else{
				putstr("yotsh: load: invalid address `");
				putstr(cp2);
				putstr("\'\r\n");
				continue;
			}
			if(strtos(cp1, &out)){
				if(out & 0x0003){
					out = (out >> 2) + 1;
				}else{
					out = (out >> 2);
				}
				loadaddr |= (out << 12);
				*(cp1 - 1) = ' ';
				return loadaddr;
			}else{
				putstr("yotsh: load: invalid number `");
				putstr(cp1);
				putstr("\'\r\n");
				continue;
			}
		}else if(!strcmp(argcopy, "halt") || 
				!strcmp(argcopy, "poweroff") || 
				!strcmp(argcopy, "shutdown")){
			asm "int 0x50";
		}else if(!strcmp(argcopy, "reboot")){
			cp1 = 0;
			asm "int 0x51";
		}else if(!strcmp(argcopy, "reload") ||
				!strcmp(argcopy, "reload2") ||
				!strcmp(argcopy, "yot16") ||
				!strcmp(argcopy, "yotrm")){
			cp1=0;
			return 0;
		}else if(!strcmp(argcopy, "yot32") ||
				!strcmp(argcopy, "yotpm") ||
				!strcmp(argcopy, "protect")){
			putstr(
				"WARNING: You cannot run any real mode program "
				"unless rebooting!\r\n"
				"Do you want to switch to protected mode ? [no] ");
			yotrl(cmdline, NULL, 3, 7);
			if(!strcmp(cmdline, "yes")){
				return (3 << 12) | 101;
			}else{
				if(cmdline[0] == 'y' || cmdline[0] == 'Y'){
					putstr("You should type `yes\'.\r\n");
				}else{
					putstr("Not confirmed.\r\n");
				}
			}
		}else if(!strcmp(argcopy, "loadgarbage")){
			cp1=0;
			return 74;
		}else if(!strcmp(argcopy, "loadnull")){
			cp1=0;
			return 57920;
		}else if(!strcmp(argcopy, "loadstupid")){
			cp1=0;
			return 73;
		}else if(!strcmp(argcopy, "clear") || 
				!strcmp(argcopy, "cls")){
			chv_clear();
			chv_reset_cursor();
			char_vga_tobios();
		}else if(!strcmp(argcopy, "help") ||
				argcopy[0] == '?'){
			cp2 = cmdline + 4;
			if(!end){
				cp2++;
			}
			for(; *cp2 == ' '; cp2++);
			if(!strcmp(cp2, "set")){
				putstr("Syntax: set [option]\r\n"
					"Type `set help\' to display option list.\r\n");
			}else if(!strcmp(cp2, "unset")){
				putstr("Syntax: unset [option]\r\n"
					"Type `set help\' to display option list.\r\n");
			}else if(!strcmp(cp2, "read")){
				putstr("Syntax: read MEM_ADDR\r\n");
			}else if(!strcmp(cp2, "tinyload")){
				putstr("Syntax: tinyload SECTOR_OFFSET\r\n");
			}else if(!strcmp(cp2, "load")){
				putstr("Syntax: load SECTOR_OFFSET SIZE_KB\r\n");
			}else if(!strcmp(cp2, "clear")){
				putstr("Syntax: clear\r\n");
			}else if(!strcmp(cp2, "halt")){
				putstr("Syntax: halt\r\n");
			}else if(!strcmp(cp2, "reboot")){
				putstr("Syntax: reboot\r\n");
			}else if(!strcmp(cp2, "reload")){
				putstr("Syntax: reload\r\n");
			}else if(!strcmp(cp2, "yot32")){
				putstr("Syntax: yot32\r\n");
			}else if(!strcmp(cp2, "loadgarbage") ||
					!strcmp(cp2, "loadstupid") ||
					!strcmp(cp2, "loadnull")){
				putstr(" You can try to guess it!\r\n"
					"     YYYYY\r\n"
					"      OOOOO\r\n"
					"       TTTTT\r\n"
					"        SSSSS\r\n"
					"         HHHHH\r\n"
					"   <!-- Unknown special command -->\r\n");
			}else{
				putstr("YOTSH command list:"
					"\r\n set         "
					"Enable shell function"
					"\r\n unset       "
					"Disable shell function"
					"\r\n read        "
					"Load a byte from memory and display it"
					"\r\n tinyload    "
					"Load a tiny program from disk (< 4KiB)"
					"\r\n load        "
					"Load a program"
					"\r\n clear       "
					"Clear the screen"
					"\r\n halt        "
					"Shutdown the computer"
					"\r\n reboot      "
					"Reboot the computer"
					"\r\n reload      "
					"Reload the shell"
					"\r\n yot32       "
					"Switch to protected mode"
					"\r\n loadgarbage "
					"Display some garbage to screen"
					"\r\n loadstupid  "
					"Infinite loop"
					"\r\n loadnull    "
					"Load a non-existent program"
					"\r\n"
					"You can press F12 to terminate a running program.\r\n");
			}
		}else if(*argcopy != '\0'){
			putstr("yotsh: invalid command `");
			putstr(argcopy);
			putstr("\'\r\n");
			putstr("Type `help\' for more information.\r\n");
		}else{
			cmdcount--;
		}
	}
	return 0;
}
