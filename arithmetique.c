#include <stdio.h>
#include <stdlib.h>
#include "sys/time.h"
#include "time.h"

#define DEG 5000000
#define bitmod 32

typedef int sfixn;

sfixn BASE_1 = bitmod - 1;

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
sfixn* addition_polynome_mod(sfixn* a, sfixn* b, sfixn p){
	sfixn*res,i;
	sfixn r;
	res = malloc(DEG*sizeof(sfixn));
	for(i=0;i<DEG;i++){
		r =(a[i]+b[i]);
		r-= p;
   		r += (r >> BASE_1) & p;
		res[i]=r;
		//res[i] = (a[i] + b[i])%p;
	}
	return res;
}

sfixn* addition_polynome(sfixn* a, sfixn* b){
	sfixn*res,i;
	res = malloc(DEG*sizeof(sfixn));
	for(i=0;i<DEG;i++){
		res[i] =(a[i]+b[i]);			
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
	srand(time(NULL));
	/* On initialise les coefficients de polynomes de degre DEG */
	for(i=0; i<DEG; i++){
		a[i]=(sfixn) (p*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) (p*((double)rand())/ RAND_MAX);
	}
	printf("%d\n",(a[DEG-1]+b[DEG-1])%p);

	res = addition_polynome_mod(a,b,p);
	printf("%d\n",res[DEG-1]);

	free(a);
	free(b);
	free(res);
	end = clock();
	time_spent = (double)(end) / CLOCKS_PER_SEC;
	printf("Le temps d'execution est de : %g\n",time_spent);
	return 0;
}
