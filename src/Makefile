# -*-
# Attempeux Jan 21 2024.
# Makefile.
# -*-

objs = main.o util.o

moasm: $(objs)
	ld -o moasm $(objs)
main.o: main.s
	as -o main.o main.s
util.o: util.s
	as -o util.o util.s
clear:
	rm -f $(objs) moasm
