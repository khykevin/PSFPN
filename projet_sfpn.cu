#include "stdio.h"
#include "stdlib.h"
#include "sys/time.h"
#include "time.h"
#include "cuda.h"


#define DEG 32767//ne marche plus a 100 000 000
#define MAX_COEF (2048*2048)
#define THREADS_PER_BLOCK 1025

typedef int sfixn;

__global__ void add(sfixn* a, sfixn* b, sfixn *p, sfixn* res, sfixn deg){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	if(ind < deg){
		res[ind]=(a[ind]+b[ind])%(*p);
	}
	
}

void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<DEG;i++){
		if(i>DEG-10)
			printf("P[%d]=%d  ",i,res[i]);
		if (res[i]>65521){
			printf("ERREUR!!!\n");
			printf("P[%d]=%d  ",i,res[i]);
		}
	}
	printf("\n");
}

int main(){
	sfixn *a, *b, p,*res; /*Copie des variables sur CPU, p*/
	sfixn *g_a, *g_b,*g_p,*g_res; /*Copie des variables sur GPU, g_p*/
	sfixn i;	
	clock_t temps;
	sfixn size=DEG*sizeof(sfixn);	

	/*On alloue les vecteur de coefficients sur le GPU*/	
	cudaMalloc((void**)&g_a, size);
	cudaMalloc((void**)&g_b, size);
	cudaMalloc((void**)&g_p, sizeof(sfixn));
	cudaMalloc((void**)&g_res, size);
	a = (sfixn*)malloc(size);
	b = (sfixn*)malloc(size);
	res = (sfixn*)malloc(size);
	srand(time(NULL));
	/* On initialise les coefficients de polynomes de degre DEG */
	for(i=0; i<DEG; i++){
		a[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
	}
	sfixn test=(a[DEG-1]+b[DEG-1])%65521;
	printf("test=%d\n",test);
	/*Le modulo p un nombre premier*/	
	p=65521;

	/*On copie sur le GPU les vecteurs initialisé sur le CPU*/
	cudaMemcpy(g_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_p, &p, sizeof(sfixn), cudaMemcpyHostToDevice);	


	/*Appel de fonction sur le GPU */
	add<<<(DEG+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,g_p,g_res,DEG);

	/*Copie du resultat du GPU sur le CPU*/
	cudaMemcpy(res, g_res, size, cudaMemcpyDeviceToHost);

	/*Liberation de l'espace aloué sur le GPU */
	affichage_polynome(res);
	cudaFree(g_a);
	cudaFree(g_b);
	cudaFree(g_p);
	cudaFree(g_res);
	
	free(a);
	free(b);
	free(res);
	temps=clock();
	printf("Le temps d'execution est de : %f\n",(double)temps/CLOCKS_PER_SEC);
	return 0;
}
