
.PHONY: all clean
.SUFFIXES: .c.o .s.o

OBJ=bccfunc.o str_out.o char_in.o str_in.o char_vga.o char_vhl.o

all: yotlibc.a

yotlibc.a: $(OBJ)
	ar86 rc $@ $(OBJ)

.s.o:
	nasm -f as86 $< -o $@
.c.o:
	bcc -ansi -Mc -c $< -o $@

clean:
	rm -f yotlibc.a $(OBJ)
