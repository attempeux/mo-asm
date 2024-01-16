# ---------------------------------------------------#
# File created by Attempeux on Jan 16 2023 program.  #
# Makefile.                                          #
# ---------------------------------------------------#
objs = main.o

moasm: $(objs)
	gcc -o moasm $(objs)
%.o: %.asm
	gcc -c $^
clear:
	rm -f $(objs) moasm
