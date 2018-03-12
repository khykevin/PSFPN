#include "global_fun.h"
#include "types.h"


// Fonction addition modulo MOD de polynomes sur Device (GPU)
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block 
	if(ind+offset < deg){
		res[ind+offset]=(a[ind+offset]+b[ind+offset])%p; 
	}
	
}

// Fonction addition de polynomes sans modulo sur Device (GPU)
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
	//printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
	
	if(ind+offset < deg){
		res[ind+offset]=a[ind+offset]+b[ind+offset];
	}
	
}


