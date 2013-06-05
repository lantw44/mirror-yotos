
.PHONY: all clean
.SUFFIXES: .c.o .s.o

# some 32-bit function not implemented
#OBJ=str_out.o char_in.o str_in.o char_vga.o char_vhl.o strbasic.o

OBJ=str_out.o char_vga.o char_vhl.o strbasic.o
LIB=yotk32.a

all: $(LIB)

$(LIB): $(OBJ)
	ar rcs $@ $(OBJ)

.s.o:
	nasm -f elf32 $< -o $@
.c.o:
	gcc -m32 -ffreestanding -fleading-underscore -c $< -o $@

clean:
	rm -f $(LIB) $(OBJ)
