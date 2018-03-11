#include "sys/time.h"
#include "time.h"
#include "global_fun.h"

// Threads par bloc
#define THREADS_PER_BLOCK 1024

/* Nombre de CUDA Cores sur GPU:
GPU1: nVidia GeForce GTX TITAN 2688 Cuda cores
GPU2: nVidia Tesla K40c 2880 Cuda cores
GPU3: nVidia Tesla P100-PCIe 3584 Cuda cores */
#define CUDA_CORES 2688

// Nombre de blocs necessaires pour l'appel de fonction CUDA, le nombre de blocs dépend du degré
#define NB_BLOCK ((DEG+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)//ne marche plus a 100 000 000

// Degré des polynômes
//#define DEG 1000000000

// Caractéristique du corps fini auquel appartiennent les coefficients
#define MOD 65521

// Indique si l'addition doit se faire modulo MOD
#define IFMOD 1

// Nombre d'opérations par thread
#define OPETHD 1


// uint64_t bug à partir de 1<<28 environ
// unsigned int bug à partir de 1<<29 environ
//long bug a 500000000

sfixn DEG=500000000;
//5254002 525500000 

// Fonction d'affichage de polynome
void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<DEG;i++){
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
		a[i]=(sfixn) ((MOD-1)*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) ((MOD-1)*((double)rand())/ RAND_MAX);
	}
	sfixn test=(a[DEG-1]+b[DEG-1]);
	sfixn test2=(a[0]+b[0])%MOD;
	if(IFMOD) test = test%MOD;
	printf("res[%d]=%d\n",0,test2);
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

	if(NB_BLOCK>CUDA_CORES){
      cut=NB_BLOCK/CUDA_CORES;
      if((NB_BLOCK%CUDA_CORES) != 0){
	      cut++;
	    }
      printf("Le nombre de blocs necessaire est de %d.\nIl est superieur au nombre de coeur du GPU qui est de %d.\nOn doit donc diviser les polynomes en %d parties afin de ne pas depasser le nombre de coeurs maximal.\n",NB_BLOCK,CUDA_CORES,cut);
	    printf("cut=%d\n",cut);
	    if(IFMOD){
	        for(i=0;i<cut;i++){
             offset=i*CUDA_CORES*THREADS_PER_BLOCK;
             if(i==cut-1){
							 int nb_block_restant=(((DEG-offset)+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK);
							 add_mod<<<nb_block_restant,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,offset);
						 }else{
		         	 add_mod<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,offset);
         		 }
         }   
	    }else{
	    		printf("IFMOD =0\n");
	        for(i=0;i<cut;i++){
		        offset=i*CUDA_CORES*THREADS_PER_BLOCK;
		        add<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,DEG,offset);
	         }  
        }
	}else{
  	printf("Le nombre de blocs necessaire est de %d.\nIl est inferieur au nombre de coeur du GPU qui est de %d.\nOn peut donc sommer les coefficients du polynome en 1 seule fois.\n",NB_BLOCK,CUDA_CORES);
		if(IFMOD==1){
    	add_mod<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,DEG,0);
    	}else{
      	add<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,DEG,0);
    	}	    
		}
 
	/*Copie du resultat du GPU sur le CPU*/
	cudaMemcpy(res, g_res, size, cudaMemcpyDeviceToHost);

	/*Liberation de l'espace alloué sur le GPU */
  //affichage_polynome(res);
  printf("P[0]=%ld\n",res[0]);
	printf("P[%d]=%ld\n",DEG-1,res[DEG-1]);
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
