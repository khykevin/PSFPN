CC =gcc
NVC = nvcc
CFLAGS =-W -Wall -std=gnu99 -pedantic -O3
<<<<<<< HEAD
NVFLAGS = -O2 -Wno-deprecated-gpu-targets
=======
NVFLAGS = -O2
>>>>>>> e60feb9dcfbc12986b018024d33f0a87ed1946fe

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
