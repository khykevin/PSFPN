#include <stdio.h>
#include <stdlib.h>
#include "sys/time.h"
#include "time.h"

#define DEG 500000000
#define MAX_COEF (2048*2048)

typedef int sfixn;

/* Fonction d'affichage des coefficients d'un polynôme */
/*
void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<DEG;i++){
		//printf("P[%d]=%d  ",i,res[i]);
	}
	printf("\n");
}
*/

/* Additionne deux polynômes a et b modulo p */
sfixn* addition_polynome(sfixn* a, sfixn* b, sfixn p){
	sfixn*res,i;
	res = malloc(DEG*sizeof(sfixn));
	for(i=0;i<DEG;i++){
		res[i]=(a[i]+b[i])%p;
		//printf("add[%d]=%d ",i,res[i]);			
	}
	return res;
}


int main(){
	sfixn *a,*b,*res,p,size,i;
	clock_t end;
	double time_spent;
	size = DEG*sizeof(sfixn);	
	a = (sfixn*)malloc(size);
	b = (sfixn*)malloc(size);
	res = (sfixn*)malloc(size);
	//debut=my_gettimeofday();/*Temps début d'execution*/
		
	p=65521;
	/* On initialise les coefficients de polynomes de degre DEG */
	for(i=0; i<DEG; i++){
		a[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
	}

	res = addition_polynome(a,b,p);
	free(a);
	free(b);
	free(res);
	end = clock();
	time_spent = (double)(end) / CLOCKS_PER_SEC;
	printf("Le temps d'execution est de : %g\n",time_spent);
	return 0;
}
