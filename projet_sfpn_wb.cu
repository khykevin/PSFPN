#include "stdio.h"
#include "stdlib.h"
#include "sys/time.h"
#include "time.h"
#include "cuda.h"
/* Traitement pour le modulo p
Probleme avec le changement du nombre de threads cela engendre une resultat errone

*/

#define DEG 1024
#define MAX_COEF 2048*2048

__global__ void add(int* a, int* b, int *p, int* res){
	res[threadIdx.x]=(a[threadIdx.x]+b[threadIdx.x])%(*p);
}

void affichage_polynome(int *res){
	int i;
	for(i=0;i<DEG;i++){
		if(i>DEG-10){
			printf("P[%d]=%d  ",i,res[i]);
		}
		if (res[i]>65521){
			printf("ERREUR!!!\n");
			printf("P[%d]=%d  ",i,res[i]);
		}
	}
	printf("\n");
}


int main(){
	int *a, *b, p,*res; /*Copie des variables sur CPU, p*/
	int *g_a, *g_b,*g_p,*g_res; /*Copie des variables sur GPU, g_p*/
	int i;	
	clock_t begin = clock();


	int size=DEG*sizeof(int);	

	/*On alloue les vecteur de coefficients sur le GPU*/	
	cudaMalloc((void**)&g_a, size);
	cudaMalloc((void**)&g_b, size);
	cudaMalloc((void**)&g_p, sizeof(int));
	cudaMalloc((void**)&g_res, size);
	
	a = (int*)malloc(size);
	b = (int*)malloc(size);
	res = (int*)malloc(size);
	srand(time(NULL));
	/* On initialise les coefficients de polynomes de degre DEG */
	for(i=0; i<DEG; i++){
		a[i]=(int) (MAX_COEF*((double)rand())/ RAND_MAX);
		b[i]=(int) (MAX_COEF*((double)rand())/ RAND_MAX);
	}
	/*Le modulo p un nombre premier*/	
	p=65521;

	/*On copie sur le GPU les vecteurs initialisé sur le CPU*/
	cudaMemcpy(g_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_p, &p, sizeof(int), cudaMemcpyHostToDevice);	


	/*Appel de fonction sur le GPU */
	add<<<1,DEG>>>(g_a,g_b,g_p,g_res);

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
	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	printf("Le temps d'execution est de : %g\n",time_spent);
	return 0;
}
