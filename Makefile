
.PHONY: all clean run

all: floppy.img

floppy.img: 55aa bootsect kernel reader
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=55aa      of=$@ bs=1   count=2    seek=510 conv=notrunc
	dd if=bootsect  of=$@ conv=notrunc
	dd if=kernel    of=$@ bs=512 seek=1 conv=notrunc
	dd if=reader	of=$@ bs=512 seek=9 conv=notrunc

bootsect: bootsect.s basic.s
	nasm -f bin $< -o $@
kernel: kernel.o
	ld86 -T 0x0000 -d kernel.o -o kernel
reader: reader.o yotlibc/yotlibc.a
	ld86 -T 0x0000 -d reader.o yotlibc/yotlibc.a -o reader

kernel.o: kernel.s
	nasm -f as86 $< -o $@
reader.o: reader.c
	bcc -ansi -Mc -Iyotlibc -c $< -o $@

55aa:
	echo "0000000: 55aa" | xxd -r > $@

run: floppy.img
	qemu-kvm -fda floppy.img $(QARG)

clean:
	rm -f bootsect kernel kernel.o 55aa reader reader.o floppy.img 
