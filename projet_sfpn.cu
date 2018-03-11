#include "stdio.h"
#include "stdlib.h"
#include "sys/time.h"
#include "time.h"
#include "cuda.h"


// Borne superieure pour les coefficients des polynomes
#define MAX_COEF (2048*2048)

// Threads par bloc
#define THREADS_PER_BLOCK 1024

/* Nombre de CUDA Cores sur GPU:
GPU1: nVidia GeForce GTX TITAN 2688 Cuda cores
GPU2: nVidia Tesla K40c 2880 Cuda cores
GPU3: nVidia Tesla P100-PCIe 3584 Cuda cores */
#define CUDA_CORES 2688

// Nombre de blocs pour l'appel de fonction CUDA
#define NB_BLOCK ((CUDA_CORES+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)//ne marche plus a 100 000 000

// Degré des polynômes
#define DEG 6000000

// Caractéristique du corps fini auquel appartiennent les coefficients
#define MOD 65521

// Indique si l'addition doit se faire modulo MOD
#define IFMOD 1

// Nombre d'opérations par thread
#define OPETHD 1


// Permet de dynamiser le type utilisé pour les opérations
typedef int sfixn;


// Fonction addition modulo MOD de polynomes sur Device (GPU)
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	if((ind+offset)==2000001)
		printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	if(ind+offset < deg){
		res[ind+offset]=(a[ind+offset]+b[ind+offset])%p;
		
	}
	
}

// Fonction addition de polynomes sans modulo sur Device (GPU)
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	if(ind < deg){
		res[ind+offset]=a[ind+offset]+b[ind+offset];
	}
	
}

// Fonction d'affichage de polynome
void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<DEG;i++){
		if(i>DEG-10)
			printf("P[%d]=%d  ",i,res[i]);
		if (res[i]>65521){
			printf("ERREUR!!!\n");
			printf("P[%d]=%d  \n",i,res[i]);
			exit(0);
		}
	}
	printf("\n");
}


// main
int main(){
	sfixn *a, *b,*res; /*Copie des variables sur CPU, p*/
	sfixn *g_a, *g_b,*g_p,*g_res; /*Copie des variables sur GPU, g_p*/
	sfixn i, cut,offset;
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
    offset=0;
	srand(time(NULL));
	/* On initialise les coefficients de polynomes de degre DEG */
	for(i=0; i<DEG; i++){
		a[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) (MAX_COEF*((double)rand())/ RAND_MAX);
	}
	sfixn test=(a[DEG-1]+b[DEG-1])%MOD;
	printf("res[%d]=%d\n",DEG-1,test);
	/*Le modulo p un nombre premier*/	

	/*On copie sur le GPU les vecteurs initialisé sur le CPU*/
	cudaMemcpy(g_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, size, cudaMemcpyHostToDevice);


	/*Appel de fonction sur le GPU */
	/* 
	  CUDA_CORES+THREAD_PER_BLOCK-1 : -permet de ne pas rajouter un block si CUDA_CORES est un multiple de THREAD_PER_BLOCK
					  -permet de rajouter un block si CUDA_CORES n'est pas un multiple de THREAD_PER_BLOCK	

	*/
	if(DEG > CUDA_CORES*THREADS_PER_BLOCK){
	  cut = DEG/(CUDA_CORES*THREADS_PER_BLOCK);
	  if(DEG % (CUDA_CORES*THREADS_PER_BLOCK) != 0){
	    cut++;
	  }
	} else {
	  cut = 1;
	}
	printf("cut=%d\n",cut);
	if(IFMOD){
	  for(i=0;i<cut;i++){
	    offset=i*CUDA_CORES*THREADS_PER_BLOCK;
		printf("cut = %d, offset = %d\n",cut,offset);    
		add_mod<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,offset);
	  }   
	}else{
	  for(i=0;i<cut;i++){
		offset=i*CUDA_CORES*THREADS_PER_BLOCK;
		add<<<CUDA_CORES*THREADS_PER_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,DEG,offset);
	  }  
    }

	/*Copie du resultat du GPU sur le CPU*/
	cudaMemcpy(res, g_res, size, cudaMemcpyDeviceToHost);

	/*Liberation de l'espace alloué sur le GPU */
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
