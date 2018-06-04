#include "sys/time.h"
#include "time.h"
#include "global_fun.h"
#include <limits.h>
#include <stdint.h>
// Threads par bloc
#define THREADS_PER_BLOCK 1024
// 0 pour addition, 1 pour multiplication
#define OPERATION 1
#define NON_CONTIGUE_ALIGNE 0
#define TEST 0
#define TMP 0
#define DIVIDE 1000
/* Nombre de CUDA Cores sur GPU:
GPU1: nVidia GeForce GTX TITAN 2688 Cuda cores
GPU2: nVidia Tesla K40c 2880 Cuda cores
GPU3: nVidia Tesla P100-PCIe 7168 Cuda cores */
// Adapter ici le nombre de coeurs
#define CUDA_CORES 2880

// Nombre de blocs necessaires pour l'appel de fonction CUDA, le nombre de blocs dépend du degré
//#define NB_BLOCK ((SIZE+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK)

// Caractéristique du corps fini auquel appartiennent les coefficients
//#define MOD 65521

// Indique si l'addition doit se faire modulo MOD
#define IFMOD 1

// Nombre d'opérations par thread


// uint64_t bug à partir de 1<<28 environ
// unsigned int bug à partir de 1<<29 environ
sfixn MOD=1009;
sfixn DEG=500000;
sfixn SIZE=DEG+1;
sfixn OPETHD=1;
sfixn NB_BLOCK=(SIZE+THREADS_PER_BLOCK*OPETHD-1)/(THREADS_PER_BLOCK*OPETHD);

// Fonction d'affichage de polynome
void affichage_polynome(sfixn *res){
	sfixn i;
	for(i=0;i<=2*(SIZE-1);i++){
		printf("P[%d]=%d \n",i,res[i]);
	}
	printf("\n");
}

// main
int main(){
	sfixn *a, *b,*res,*tmp; /*Copie des variables sur CPU, p*/
	sfixn *g_a, *g_b,*g_p,*g_res,*g_tmp; /*Copie des variables sur GPU, g_p*/
	sfixn i, cut,offset;
  sfixn* test_arit;
	clock_t temps_total;
	clock_t temps_malloc_debut,temps_malloc_fin;
	clock_t temps_memcpy_host_to_device_debut,temps_memcpy_host_to_device_fin;
	clock_t temps_init_debut,temps_init_fin;
	clock_t temps_calcul_debut,temps_calcul_fin;
	//clock_t temps_memcpy_device_to_host_debut, temps_memcpy_device_to_host_fin;
	double temps_pourcent_malloc;
	double temps_pourcent_init;
	double temps_pourcent_calcul;
	double temps_pourcent_memcpy_htod;
	//double temps_pourcent_memcpy_dtoh;
	double size=SIZE*sizeof(sfixn);
	/*On alloue les vecteur de coefficients sur le GPU*/	
	temps_malloc_debut=clock();
	cudaMalloc((void**)&g_a, size);
	cudaMalloc((void**)&g_b, size);
	cudaMalloc((void**)&g_p, sizeof(sfixn));
	a = (sfixn*)malloc(size);
	b = (sfixn*)malloc(size);
	
	/*
	cudaDeviceProp  prop;
	cudaGetDeviceProperties( &prop, 0 );
  int blocks = prop.multiProcessorCount;
  int mem = prop.sharedMemPerBlock;
  printf("prop.multiProcessorCount=%d\n",blocks); 
  int deviceCount;
	cudaGetDeviceCount(& deviceCount);
	printf("deviceCount=%d  && mem_partage=%d\n",deviceCount,mem);
	for(i=0;i<3;i++)
		printf("max grid=%d\n",prop.maxGridSize[i]); 
	*/ 
	
	if(OPERATION){
    res = (sfixn*)malloc(2*size);
    memset(res, 0, 2*SIZE*sizeof(sfixn));
    cudaMalloc((void**)&g_res, 2*size);
    cudaMalloc((void**)&g_tmp,DIVIDE*size);
    tmp = (sfixn*)malloc(DIVIDE*size);
  } else { 
    res = (sfixn*)malloc(size);
    cudaMalloc((void**)&g_res, size);
  }
  temps_malloc_fin=clock();
	printf("L'allocation mémoire des differents tableaux prend %fs\n",(double)(temps_malloc_fin-temps_malloc_debut)/CLOCKS_PER_SEC);
  offset=0;
	srand(time(NULL));
	/* On initialise les coefficients de polynomes de degre SIZE */
	temps_init_debut=clock();
	for(i=0; i<SIZE; i++){
		a[i]=(sfixn) ((MOD)*((double)rand())/ RAND_MAX);
		b[i]=(sfixn) ((MOD)*((double)rand())/ RAND_MAX);
		/*a[i]=i%11;
		b[i]=(i+1)%11;*/
		//printf("a[%d]=%d && b[%d]=%d \n",i,a[i],i,b[i]);
	}	
	temps_init_fin=clock();
	printf("L'initialisation des polynomes a et b %fs\n",(double)(temps_init_fin-temps_init_debut)/CLOCKS_PER_SEC);
  if(OPERATION){
	  if(TEST){
	  	test_arit = (sfixn*)malloc(2*size);
	  	memset(test_arit, 0, 2*SIZE*sizeof(sfixn));
	  	test_arit=multiplication_polynome_mod(a,b,MOD,SIZE);
	  	printf("test_arit[%d]=%d\n",0,test_arit[0]); 
	  }
  } else {	
  	if(IFMOD){
  		printf("res[%d]=%d\n",0,(a[0]+b[0])%MOD);    	
  		printf("res[%d]=%d\n",(SIZE-1),(a[SIZE-1]+b[SIZE-1])%MOD);
		}else{
			printf("res[%d]=%d\n",0,(a[0]+b[0]));
			printf("res[%d]=%d\n",(SIZE-1),(a[SIZE-1]+b[SIZE-1]));
		}
  }

	/*Le modulo p un nombre premier*/	

	/*On copie sur le GPU les vecteurs initialisé sur le CPU*/
	temps_memcpy_host_to_device_debut=clock();
	cudaMemcpy(g_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(g_b, b, size, cudaMemcpyHostToDevice);
  if(OPERATION) cudaMemcpy(g_res, res, 2*size, cudaMemcpyHostToDevice);
	temps_memcpy_host_to_device_fin=clock();
	printf("La copie des tableaux du CPU vers le GPU prend %fs\n",(double)(temps_memcpy_host_to_device_fin-temps_memcpy_host_to_device_debut)/CLOCKS_PER_SEC);
	/*Appel de fonction sur le GPU */
	/* 
	  CUDA_CORES+THREAD_PER_BLOCK-1 : -permet de ne pas rajouter un block si CUDA_CORES est un multiple de THREAD_PER_BLOCK
					  -permet de rajouter un block si CUDA_CORES n'est pas un multiple de THREAD_PER_BLOCK	

		VERSION SIZE op/thread (ERRONE) : 
		mult_mod_multhd<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE);
		
		VERSION 1 op/thread  :
		for(i=0;i<SIZE;i++){
    	mult_mod<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,i);
    }
		
		VERSION OPTHD op/thread  : 
		for(i=0;i<SIZE;i++){
    	mult_mod_multhd2<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,i,OPETHD);
    }
		
		VERSION TMP :
		sfixn cpt,j;
		sfixn nb_iter=SIZE/DIVIDE;
		sfixn nb_block_mul=(DIVIDE+THREADS_PER_BLOCK*OPETHD-1)/(THREADS_PER_BLOCK*OPETHD);
		
		//mult_mod_multhd<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_tmp,SIZE);
		for(cpt=1;cpt<=nb_iter;cpt++){
			//printf("nb_iter = %d\n",nb_iter);
			mult_mod_multhd_tmp<<<nb_block_mul,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_tmp,cpt,DIVIDE,SIZE);
			//cudaDeviceSynchronize();
			cudaMemcpy(tmp, g_tmp,DIVIDE*size, cudaMemcpyDeviceToHost);
			for(i=0;i<SIZE;i++){
				for(j=0;j<DIVIDE;j++){
					//res[i+j+(cpt-1)*DIVIDE]=(res[i+j+(cpt-1)*DIVIDE]+tmp[i+j*SIZE])%MOD;
					res[i+j+(cpt-1)*DIVIDE]=(res[i+j+(cpt-1)*DIVIDE]+tmp[i+j*SIZE]);
					ADD_SCALAR_SHIFT(MOD,res[i+j+(cpt-1)*DIVIDE]);
				}
			}
		}
		
		
		}
	*/
	
	temps_calcul_debut=clock();
  if(OPERATION){
  	printf("NB BLOCK=%d\n",NB_BLOCK);
  	printf("Multiplication naive sur GPU\n");
  		
  	
  	/*sfixn nb_bloc=(2*SIZE-1)/(THREADS_PER_BLOCK);
  	if(((2*SIZE-1)%THREADS_PER_BLOCK)!=0)
  		nb_bloc++;
  	*/
  	
  	/*sfixn nb_bloc=28;
  	printf("nb bloc=%d\n",nb_bloc);
  	sfixn T=(2*SIZE-1)/(THREADS_PER_BLOCK*nb_bloc);
		if((2*SIZE-1)%(THREADS_PER_BLOCK*nb_bloc)!=0)
			T++;
		printf("T=%d\n",T);*/
		
		
		sfixn T=2;
		sfixn nb_bloc=(2*SIZE-1)/(T*THREADS_PER_BLOCK);
  	if(((2*SIZE-1)%THREADS_PER_BLOCK)!=0)
  		nb_bloc++;		
  	//sfixn max_uint=UINT_MAX;
		printf("T=%d et nb_bloc=%d\n",T,nb_bloc);
		sfixn mod2=(MOD-1)*(MOD-1);
		sfixn iter=UINT_MAX/(mod2);
  	printf("UINT_MAX=%u\n",UINT_MAX);
  	printf("iter=%u\n",iter);
  	sfixn max_uint=UINT_MAX-(MOD-1);
  	printf("UINT_MAX-(MOD-1)=%u\n",max_uint);
  	sfixn nb=(2*SIZE)/T;
  	if((2*SIZE)%T!=0)
  		nb++;
  	printf("nb=%d\n",nb);
  	printf("nb_iter=%d\n",iter);
  	//test<<<nb_bloc,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,T);
  	//mult_mod_repart_non_contigue<<<nb_bloc,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,T,nb);
  	//mult_mod_repart_iter<<<nb_bloc,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,T,iter);
  	//test<<<nb_bloc,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,T);
  	//mult_mod_repart<<<nb_bloc,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,T);
  	//mult_mod_multhd<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE);
  	//mult_mod_share<<<NB_BLOCK,THREADS_PER_BLOCK,(2*SIZE-1)*sizeof(sfixn)>>>(g_a,g_b,MOD,g_res,SIZE);
		
		mult_mod_repart<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,NB_BLOCK);
  	
  	/*for(i=0;i<SIZE;i++){
    	mult_mod<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,i);
    }*/
        
    /*for(i=0;i<SIZE;i++){
    	mult_mod_multhd2<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,i,OPETHD);
    }*/
  	
  	//cudaDeviceSynchronize();
    //printf("Karatsuba sur GPU\n");
    /*karatsuba<<<1,1>>>(g_a,g_b,MOD,g_res,SIZE);
  
  
  	*/
  	if(NON_CONTIGUE_ALIGNE){
			sfixn e=0;
			sfixn j;
		  sfixn* res1 = (sfixn*)malloc(2*size);
		  memset(res1, 0, 2*size);
		  cudaMemcpy(res1, g_res, 2*size-1, cudaMemcpyDeviceToHost);
		  for(i=0;i<nb;i++){
		  	for(j=0;j<T;j++){
		  		res[i+j*nb]=res1[e];
		  		e++;
		  	}	
		  }
  	}
  } else {
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
						 int nb_block_restant=(((SIZE-offset)+(THREADS_PER_BLOCK*OPETHD)-1)/(THREADS_PER_BLOCK*OPETHD));
						 printf("nb_block_restant = %d\n",nb_block_restant); 
						 add_mod_multhd<<<nb_block_restant,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,offset,OPETHD);
					 }else{
			     	add_mod_multhd <<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,offset,OPETHD);
			 		 }
				}    
		}else{
			printf("IFMOD =0\n");
			for(i=0;i<cut;i++){
			  offset=i*CUDA_CORES*THREADS_PER_BLOCK;
			  if(i==cut-1){
					printf("offset = %d\n",offset);              
					sfixn nb_block_restant2=(((SIZE-offset)+(THREADS_PER_BLOCK*OPETHD)-1)/(THREADS_PER_BLOCK*OPETHD));
					printf("nb_block_restant = %d\n",nb_block_restant2); 
					add<<<nb_block_restant2,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,SIZE,offset);
				}else{
			  	add<<<CUDA_CORES,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,SIZE,offset);
			  }
			}  
	 	}
	 }else{
  	printf("Le nombre de blocs necessaire est de %d.\nIl est inferieur au nombre de coeur du GPU qui est de %d.\nOn peut donc sommer les coefficients du polynome en 1 seule fois.\n",NB_BLOCK,CUDA_CORES);
	  if(IFMOD==1){
    	add_mod_multhd<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,MOD,g_res,SIZE,0,OPETHD);
    }else{
      add<<<NB_BLOCK,THREADS_PER_BLOCK>>>(g_a,g_b,g_res,SIZE,0);
    	}	    
	  }
  }
 	
	//printf("Le calcul prend %fs\n",(double)(temps_calcul_fin-temps_calcul_debut)/CLOCKS_PER_SEC);
	/*Copie du resultat du GPU sur le CPU*/
	//temps_memcpy_device_to_host_debut=clock();
	if(OPERATION && !TMP && !NON_CONTIGUE_ALIGNE){
		cudaMemcpy(res, g_res, 2*size-1, cudaMemcpyDeviceToHost);
  } 
  if(!OPERATION) {
    cudaMemcpy(res, g_res, size, cudaMemcpyDeviceToHost);
  }
  //temps_memcpy_device_to_host_fin=clock();
	//printf("La copie des tableaux du GPU vers le CPU prend %fs\n",(double)(temps_memcpy_device_to_host_fin-temps_memcpy_device_to_host_debut)/CLOCKS_PER_SEC);
	temps_calcul_fin=clock();
	printf("Le calcul prend %fs\n",(double)(temps_calcul_fin-temps_calcul_debut)/CLOCKS_PER_SEC);
	
	
	/*Liberation de l'espace alloué sur le GPU */
  //affichage_polynome(res);
	if(OPERATION){
		if(TEST){
			printf("P[0]=%d\n",test_arit[0]);
			printf("P[%d]=%d\n",2*(SIZE-1),test_arit[2*(SIZE-1)]);
			printf("TEST\n");
			for(i=0;i<=2*(SIZE-1);i++){
				if(res[i]!=test_arit[i]){
					printf("ERREUR à l'indice i=%d CPU=%d et GPU=%d\n",i,test_arit[i],res[i]);
				}
			}
			free(test_arit);
		}
		//printf("P[0]=%d\n",res[0]);
		/*printf("P[1]=%d\n",res[1]);
	  printf("P[%d]=%d\n",2*(SIZE-1),res[2*(SIZE-1)]);*/
	  	  
	} else {
		printf("P[%d]=%d\n",0,res[0]);
	  printf("P[%d]=%d\n",(SIZE-1),res[(SIZE-1)]);
	  printf("VERIFICATION\n");
	  if(IFMOD){
	  	printf("P[%d]=%d\n",0,(a[0]+b[0])%MOD);
	  	printf("P[%d]=%d\n",(SIZE-1),(a[SIZE-1]+b[SIZE-1])%MOD);
	  }else{
	  	printf("P[%d]=%d\n",0,(a[0]+b[0]));
	  	printf("P[%d]=%d\n",(SIZE-1),(a[SIZE-1]+b[SIZE-1]));
	  }
	}
	cudaFree(g_a);
	cudaFree(g_b);
	cudaFree(g_p);
	cudaFree(g_res);
	if(TMP){
		cudaFree(g_tmp);
		free(tmp);
	}
	free(a);
	free(b);
	free(res);
	
	
	temps_total=clock();
	temps_pourcent_init=(double)(((double)temps_init_fin-(double)temps_init_debut)/(double)temps_total)*100;
	temps_pourcent_malloc=(double)(((double)temps_malloc_fin-(double)temps_malloc_debut)/(double)temps_total)*100;
	temps_pourcent_memcpy_htod=(double)(((double)temps_memcpy_host_to_device_fin-(double)temps_memcpy_host_to_device_debut)/(double)temps_total)*100;
	temps_pourcent_calcul=(double)(((double)temps_calcul_fin-(double)temps_calcul_debut)/(double)temps_total)*100;
	//temps_pourcent_memcpy_dtoh=(double)(((double)temps_memcpy_device_to_host_fin-(double)temps_memcpy_device_to_host_debut)/(double)temps_total)*100;
	printf("----------------REPARTITION TEMPS: -----------------\n");
	printf("L'allocation prend %f %% du temps total\n",(double)temps_pourcent_malloc);
	printf("L'initialisation prend %f %% du temps total\n",(double)temps_pourcent_init);
	printf("La copie des tableaux du CPU vers le GPU prend %f %% du temps total\n",(double)temps_pourcent_memcpy_htod);
	printf("Le calcul prend %f %% du temps total\n",(double)temps_pourcent_calcul);
	//printf("La copie des tableaux du GPU vers le CPU prend %f %% du temps total\n",(double)temps_pourcent_memcpy_dtoh);		
	printf("Le temps_total d'execution est de : %fs\n",(double)temps_total/CLOCKS_PER_SEC);
	
	
	return 0;
}
