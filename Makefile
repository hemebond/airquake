CC=fteqcc64
CFLAGS=-Wall -O3


all: progs.dat


progs.dat: $(wildcard qc/*.qc) ./qc/progs.src
	$(CC) $(CFLAGS) -srcfile qc/progs.src

tga2spr:
	$(CC) tools/tga2spr.c -o tga2spr

.PHONY: all
