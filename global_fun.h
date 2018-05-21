#ifndef _GLOBAL_FUN_H_
#define _GLOBAL_FUN_H_

#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "cuda.h"
//#include "global_vars.h"

#define MOD_PERCENT(p,r) ({r=r%p;})
#define ADD_SCALAR_SHIFT(p,r) ({r-= p; r += (r >> 31) & p;})
#define ADD_SCALAR_IF(p,r) ({if(r>=p){r-=p;}})

__global__ void affiche_polynome(sfixn *res, sfixn size);
__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T);
//__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn nb_bloc);
__global__ void mult_mod_share(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg);
/*void karatsuba(sfixn* kar, sfixn* a,sfixn* b, sfixn size, sfixn p);
__global__ void karatsuba_gpu(sfixn* kar, sfixn* h0, sfixn* h0inv, sfixn* h2inv, sfixn* suma, sfixn* sumb, sfixn* sum1, sfixn* sum2, sfixn* h1, sfixn* h2, sfixn* h1dec, sfixn* h2dec,  sfixn* a, sfixn* b, sfixn* a0, 		sfixn* a1,sfixn* b0, sfixn* b1,sfixn size, sfixn p);
__device__ void karatsuba_rec(sfixn* kar, sfixn* h0, sfixn* h0inv, sfixn* h2inv, sfixn* suma, sfixn* sumb, sfixn* sum1, sfixn* sum2, sfixn* h1, sfixn* h2, sfixn* h1dec, sfixn* h2dec,  sfixn* a, sfixn* b, sfixn* a0, 		sfixn* a1,sfixn* b0, sfixn* b1,sfixn size, sfixn p);*/
__device__ void decalage_void(sfixn* dec, sfixn *tab, sfixn size, sfixn n);
__device__ void somme_void(sfixn* sum, sfixn *a, sfixn *b, sfixn size_a, sfixn size_b, sfixn p);
__device__ void oppose_void(sfixn* op, sfixn* tab, sfixn size, sfixn p);
//__global__ void karatsuba_void(sfixn* kar, sfixn* a,sfixn* b, sfixn size, sfixn p);
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset);
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset);
__global__ void add_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread);
__global__ void mult_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg);
__global__ void mult_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn i);
__global__ void mult_tat_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread);
__global__ void mult_mod_multhd2(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn i, sfixn op_thread);
__global__ void mult_mod_multhd_tmp(sfixn* a, sfixn* b, sfixn p, sfixn* tmp, sfixn cpt, sfixn divide, sfixn deg);
sfixn* multiplication_polynome_mod(sfixn* a, sfixn* b, sfixn p,sfixn deg);
#endif
