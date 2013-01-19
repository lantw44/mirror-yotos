#include "yotlibc.h"

int strcmp(s1, s2)
	char* s1;
	char* s2;
{
	char* str1;
	char* str2;
	if((*s1 | *s2) && (!*s1 || !*s2)){
		if(*s1){
			return 1;
		}else{
			return -1;
		}
	}
	for(str1=s1, str2=s2; *str1 != '\0' && *str2 != '\0'; str1++, str2++){
		if(*str1 > *str2){
			return 2;
		}else if(*str1 < *str2){
			return -2;
		}
	}
	if(*str1 != '\0'){
		return 3;
	}
	if(*str2 != '\0'){
		return -3;
	}
	return 0;
}

int strtos(str, store)
	char* str;
	unsigned int* store;
{
	unsigned int result = 0;
	bool ishex = false;
	if(*str == '0' && (*(str+1) == 'x' || *(str+1) == 'X')){
		str += 2;
		ishex = true;
	}
	for(; *str != '\0'; str++){
		if(*str >= '0' && *str <= '9'){
			if(ishex){
				result <<= 4;
				result += *str - '0';
			}else{
				result *= 10;
				result += *str - '0';
			}
		}else if(*str >= 'A' && *str <= 'F'){
			if(ishex){
				result <<= 4;
				result += *str - 'A' + 10;
			}else{
				return 0;
			}
		}else if(*str >= 'a' && *str <= 'f'){
			if(ishex){
				result <<= 4;
				result += *str - 'a' + 10;
			}else{
				return 0;
			}
		}else if(*str == ' ' || *str == '\t' || *str == '\n'){
			break;
		}else{
			return 0; /* Failed */
		}
	}
	*store = result;
	return 1;  /* OK */
}
