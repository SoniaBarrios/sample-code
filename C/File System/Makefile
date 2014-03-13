#
# A makefile for the fisk filesystem
#

# VARIABLES-------------------------------------------------
# Compiler is the GNU C Compiler

CC=gcc

# Flags
#	Show all reasonable warnings (Wall) 
#	Support multithreading (pthreads)

CFLAGS = -Wall

# COMPILING-------------------------------------------------

all: filesystem

filesystem: main.o
	$(CC) $(CFLAGS) -o filesystem main.o
	
main.o: main.c
	$(CC) $(CFLAGS) -c main.c

clean:
	rm -f *.o filesystem
	rm -f disk