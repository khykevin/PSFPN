#include "stdio.h"
#include "stdlib.h"
#include "sys/time.h"
#include "time.h"
#include "cuda.h"
#include "stdint.h"


// Borne superieure pour les coefficients des polynomes
#define MAX_COEF (2048*2048)

// Threads par bloc
#define THREADS_PER_BLOCK 1024

/* Nombre de CUDA Cores sur GPU:
GPU1: nVidia GeForce GTX TITAN 2688 Cuda cores
GPU2: nVidia Tesla K40c 2880 Cuda cores
GPU3: nVidia Tesla P100-PCIe 3584 Cuda cores */
#define CUDA_CORES 2688

// Nombre de blocs necessaires pour l'appel de fonction CUDA, le nombre de blocs dépend du degré


// Degré des polynômes
//#define DEG 1000000000

// Caractéristique du corps fini auquel appartiennent les coefficients
#define MOD 65521

// Indique si l'addition doit se faire modulo MOD
#define IFMOD 1
#define D 3072

// Nombre d'opérations par thread




// Permet de dynamiser le type utilisé pour les opérations
typedef int sfixn;

// uint64_t bug à partir de 1<<28 environ
// unsigned int bug à partir de 1<<29 environ
//long bug a 500000000
sfixn OPETHD=2;
sfixn DEG=500000000;
sfixn NB_BLOCK= ((DEG+THREADS_PER_BLOCK*OPETHD-1)/(THREADS_PER_BLOCK*OPETHD));
//5254002 525500000 


// Fonction addition modulo MOD de polynomes sur Device (GPU)
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread){
	sfixn i;
	sfixn ind=op_thread*threadIdx.x+blockIdx.x*blockDim.x*op_thread;  //blockDim.x correspond au nombre de threads par block 
	for(i=0;i<op_thread;i++){
		if(ind+offset+i < deg){
			res[ind+offset+i]=(a[ind+offset+i]+b[ind+offset+i])%p;
			if(ind+offset+i == deg-1){
				printf("res=%d\n",res[ind+offset+i]);
				}
		}
	}
	
}

// Fonction addition de polynomes sans modulo sur Device (GPU)
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	
	if(ind+offset < deg){
		res[ind+offset]=a[ind+offset]+b[ind+offset];
	}
	
}

// Fonction d'affichage de polynome
void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<DEG;i++){
		if(i==9)
			printf("P[%d]=%d  ",i,res[i]);
		if(i==DEG-1)
			printf("P[%d]=%d  ",i,res[i]);
		if (IFMOD && res[i]>65521){
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
	sfixn test=(a[DEG-1]+b[DEG-1]);
	sfixn test2=(a[0]+b[0])%MOD;
	sfixn test3=(a[D]+b[D])%MOD;
	if(IFMOD) test = test%MOD;
	printf("res[%d]=%d\n",0,test2);
	printf("res[%d]=%d\n",D,test3);
	printf("res[%d]=%d\n",DEG-1,test);
	/*Le modulo p un nombre premier*/	

	/*On copie sur le GPU les vecteurs initialisé sur le CPU*/
	cudaMemcpy(g_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, size, cudaMemcpyHostToDevice);


	/*Appel de fonction sur le GPU */
	/* 
	  DEG+THREAD_PER_BLOCK-1 : -permet de ne pas rajouter un block si CUDA_CORES est un multiple de THREAD_PER_BLOCK
					  -permet de rajouter un block si DEG n'est pas un multiple de THREAD_PER_BLOCK	

	*/

	if(NB_BLOCK>CUDA_CORES){
      cut=NB_BLOCK/CUDA_CORES;
      if((NB_BLOCK%CUDA_CORES) != 0){
	      cut++;
	    }
      printf("Le nombre de blocs necessaire est de %d.\nIl est superieur au nombre de coeur du GPU qui est de %d.\nOn doit donc diviser les polynomes en %d parties afin de ne pas depasser le nombre de coeurs maximal.\n",NB_BLOCK,CUDA_CORES,cut);
	    printf("cut=%d\n",cut);
	    if(IFMOD){
	        for(i=0;i<cut;i++){
             offset=i*CUDA_CORES*THREADS_PER_BLOCK*OPETHD;
             if(i==cut-1){
							 printf("offset = %d\n",offset);              
							 int nb_block_restant=(((DEG-offset)+(THREADS_PER_BLOCK*OPETHD)-1)/(THREADS_PER_BLOCK*OPETHD));
							 printf("nb_block_restant = %d\n",nb_block_restant); 
							 add_mod<<<nb_block_restant,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,offset,OPETHD);
						 }else{
		         	 add_mod<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,offset,OPETHD);
         		 }
         }   
	    }else{
	    		printf("IFMOD =0\n");
	        for(i=0;i<cut;i++){
		        offset=i*CUDA_CORES*THREADS_PER_BLOCK;
		        add<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,DEG,offset,OPETHD);
	         }  
        }
	}else{
  	printf("Le nombre de blocs necessaire est de %d.\nIl est inferieur au nombre de coeur du GPU qui est de %d.\nOn peut donc sommer les coefficients du polynome en 1 seule fois.\n",NB_BLOCK,CUDA_CORES);
		if(IFMOD==1){
    	add_mod<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,0,OPETHD);
    }else{
      add<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,DEG,0,OPETHD);
    	}	    
		}
 
	/*Copie du resultat du GPU sur le CPU*/
	cudaMemcpy(res, g_res, size, cudaMemcpyDeviceToHost);

	/*Liberation de l'espace alloué sur le GPU */
  //affichage_polynome(res);
  printf("P[0]=%d\n",res[0]);
  printf("P[%d]=%d\n",D,res[D]);
	printf("P[%d]=%d\n",DEG-1,res[DEG-1]);
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
