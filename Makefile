CC=fteqcc64
CFLAGS=-Wall -O3


progs.dat: $(wildcard qc/*.qc) ./qc/progs.src
	$(CC) $(CFLAGS) -srcfile qc/progs.src


all: progs.dat
