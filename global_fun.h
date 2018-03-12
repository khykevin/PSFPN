#ifndef _GLOBAL_FUN_H_
#define _GLOBAL_FUN_H_

#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "cuda.h"


void affichage_polynome(sfixn *res);

__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset);
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset);
__global__ void add_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread);
__global__ void add_multhd(sfixn* a, sfixn* b, sfixn* res, sfixn deg, sfixn offset, sfixn op_thread);

#endif

