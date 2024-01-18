# ---------------------------------------------------#
# File created by Attempeux on Jan 16 2024 program.  #
# Makefile.                                          #
# ---------------------------------------------------#
objs = main.o help.o

moasm: $(objs)
	ld -o moasm $(objs)

main.o: main.s
	as -o main.o -g main.s

help.o: help.s
	as -o help.o -g help.s

clear:
	rm -f $(objs) moasm
