#include "stdio.h"
#include "stdlib.h"
#include "time.h"
int main(){
	clock_t begin = clock();
	printf("hello world !!!\n");
	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	printf("Le temps d'execution est de : %g\n",time_spent);
	return 0;
}
