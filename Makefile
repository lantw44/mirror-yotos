
.PHONY: all clean run
.SUFFIXES: .c.o .s.o

FDIMAGE=floppy.img
BINARY=bootsect 55aa kernel yotsh reader while1 pmboot pmkern
YOT16_LIBC=yotlibc/yotlibc.a
YOT32_KLIB=yotk32/yotk32.a

QEMU=qemu-kvm
RM=rm -f

all: floppy.img

floppy.img: $(BINARY)
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=55aa      of=$@ bs=1   count=2    seek=510 conv=notrunc
	dd if=bootsect  of=$@ conv=notrunc
	dd if=kernel    of=$@ bs=512 seek=1   conv=notrunc
	dd if=yotsh     of=$@ bs=512 seek=32  conv=notrunc
	dd if=while1    of=$@ bs=512 seek=72  conv=notrunc
	dd if=reader    of=$@ bs=512 seek=73  conv=notrunc
	dd if=pmboot    of=$@ bs=512 seek=100 conv=notrunc
	dd if=pmkern    of=$@ bs=512 seek=101 conv=notrunc

.c.o: 
	bcc -ansi -Mc -Iyotlibc -c $< -o $@
.s.o:
	nasm -f as86 $< -o $@

bootsect: bootsect.s basic.s
	nasm -f bin $< -o $@
55aa:
	echo "0000000: 55aa" | xxd -r > $@
kernel: kernel.o
	ld86 -T 0x0000 -d $^ -o $@

yotsh: yotsh.o $(YOT16_LIBC)
	ld86 -T 0x0000 -d $^ -o $@
reader: reader.o $(YOT16_LIBC)
	ld86 -T 0x0000 -d $^ -o $@
while1: while1.o $(YOT16_LIBC)
	ld86 -T 0x0000 -d $^ -o $@

pmboot: pmgdt.s
	nasm -f bin -dload_offset=0x00500 -dpmkernel=0x00700 $< -o $@
pmkern: pmkern.o pmint.o $(YOT32_KLIB)
	ld -melf_i386 -Ttext 0x00700 $^ --oformat binary -o $@

pmkern.o: pmkern.s
	nasm -f elf32 $< -o $@
pmint.o: pmint.c
	gcc -m32 -masm=intel -ffreestanding -fleading-underscore \
		-Iyotk32 -c $< -o $@


$(YOT16_LIBC):
	$(MAKE) -C yotlibc
$(YOT32_KLIB):
	$(MAKE) -C yotk32

run: floppy.img
	$(QEMU) -fda $(FDIMAGE) $(QARG)

clean:
	$(RM) $(FDIMAGE) $(BINARY) kernel.o reader.o while1.o yotsh.o \
		pmkern.o pmint.o
	$(MAKE) -C yotlibc clean
	$(MAKE) -C yotk32 clean
