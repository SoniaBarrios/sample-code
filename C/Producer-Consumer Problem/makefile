# Makefile for Michael Dean's CSc360 Assignment #2, Part #1

# VARIABLES-------------------------------------------------
# Compiler is the GNU C Compiler

CC=gcc

# Flags
#	Show all reasonable warnings (Wall) 
#	Support multithreading (pthreads)

CFLAGS = -Wall

# COMPILING-------------------------------------------------

all: prodcons

prodcons: main.o
	$(CC) $(CFLAGS) -o prodcons main.o
	
main.o: main.c
	$(CC) $(CFLAGS) -c main.c

clean:
	rm -f *.o prodcons