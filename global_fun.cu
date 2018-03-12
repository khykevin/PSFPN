#include "global_fun.h"
#include "types.h"

// Fonction addition modulo MOD de polynomes sur Device (GPU)
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	sfixn r;
	if(ind+offset < deg){
		r=(a[ind+offset]+b[ind+offset]);
		r-= p;
   		r += (r >> 31) & p;
		res[ind+offset] = r;
		/*if(r >= p){
			r-=p;
		}
		res[ind+offset] = r;*/
		//res[ind+offset] = (a[ind+offset]+b[ind+offset])%p;


// Fonction addition de polynomes sans modulo sur Device (GPU)
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	
	if(ind+offset < deg){
		res[ind+offset]=a[ind+offset]+b[ind+offset];
	}
	
}

// Fonction addition modulo MOD de polynomes sur Device (GPU) avec multiples opérations par thread
__global__ void add_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread){
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


// Fonction addition de polynomes sans modulo sur Device (GPU) avec multiples opérations par thread
__global__ void add_multhd(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	
	if(ind+offset < deg){
		res[ind+offset]=a[ind+offset]+b[ind+offset];
	}
	
}

