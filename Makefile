CC =gcc
NVC = nvcc
CFLAGS =-W -Wall -std=gnu99 -pedantic -O3
NVFLAGS = -O2

.SUFFIXES:
.PHONY: all clean projet arithmetique

all: projet arithmetique

projet: projet.cu global_fun.cu
	$(NVC) $(NVFLAGS) -o projet projet.cu global_fun.cu

arithmetique: arithmetique.o
	$(CC) $(CFLAGS) -o arithmetique arithmetique.o
	
arithmetique.o: arithmetique.c
	$(CC) $(CFLAGS) -o arithmetique.o -c arithmetique.c

clean: 
	find . -type f -executable | xargs rm
	rm *.o
