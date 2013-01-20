#include "yotk32.h"

void putint(unsigned long toprint){
	char printbuf[12];
	int i = 0;
	do{
		printbuf[i] = toprint % 10 + '0';
		toprint /= 10;
		i++;
	}while(toprint > 0);
	for(i--; i>=0; i--){
		chv_putchar(printbuf[i]);
	}
}

void putcharhex(char c){
	char clist[] = {
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
		'A', 'B', 'C', 'D', 'E', 'F'};

	chv_putchar(clist[((c & 0xF0) >> 4)]);
	chv_putchar(clist[(c & 0x0F)]);
}

void putstr(const char* s){
	for(; *s; s++){
		chv_putchar(*s);
	}
}
