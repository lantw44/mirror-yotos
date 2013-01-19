
.PHONY: all clean run
.SUFFIXES: .c.o .s.o

all: floppy.img

floppy.img: 55aa bootsect kernel yotsh reader while1
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=55aa      of=$@ bs=1   count=2    seek=510 conv=notrunc
	dd if=bootsect  of=$@ conv=notrunc
	dd if=kernel    of=$@ bs=512 seek=1  conv=notrunc
	dd if=yotsh     of=$@ bs=512 seek=32 conv=notrunc
	dd if=while1    of=$@ bs=512 seek=72 conv=notrunc
	dd if=reader    of=$@ bs=512 seek=73 conv=notrunc

.c.o: 
	bcc -ansi -Mc -Iyotlibc -c $< -o $@
.s.o:
	nasm -f as86 $< -o $@

bootsect: bootsect.s basic.s
	nasm -f bin $< -o $@
kernel: kernel.o
	ld86 -T 0x0000 -d kernel.o -o kernel

yotsh: yotsh.o yotlibc/yotlibc.a
	ld86 -T 0x0000 -d yotsh.o yotlibc/yotlibc.a -o yotsh
reader: reader.o yotlibc/yotlibc.a
	ld86 -T 0x0000 -d reader.o yotlibc/yotlibc.a -o reader
while1: while1.o yotlibc/yotlibc.a
	ld86 -T 0x0000 -d while1.o yotlibc/yotlibc.a -o while1

55aa:
	echo "0000000: 55aa" | xxd -r > $@

yotlibc/yotlibc.a:
	$(MAKE) -C yotlibc

run: floppy.img
	qemu-kvm -fda floppy.img $(QARG)

clean:
	rm -f bootsect kernel kernel.o reader.o while1.o \
		55aa yotsh yotsh.o floppy.img 
