#include "global_fun.h"
#include "types.h"


// Fonction d'affichage de polynome
__global__ void affiche_polynome(sfixn *res, sfixn size){
	sfixn i;
	for(i=size-10;i<size;i++){
		printf("P[%d]=%d\n",i,res[i]);
	}
	printf("\n");
}



/*
void karatsuba(sfixn* kar, sfixn* a,sfixn* b, sfixn size, sfixn p){
		sfixn *a0;
		sfixn *a1;
		sfixn *b0;
		sfixn *b1;
		sfixn* h0;
		sfixn* h1;
		sfixn* h2;
		sfixn* h1dec;
		sfixn* h2dec;
		sfixn* h0inv;
		sfixn* h2inv;
		sfixn* sum1;
		sfixn* sum2;
		sfixn* suma;
		sfixn* sumb;
		sfixn m=size/2;
	  cudaMalloc((void**)&a0,m*sizeof(sfixn));
	  if(a0==NULL){
		  printf("karatsuba : a0\n");
		  exit(0);
	  }
	  cudaMalloc((void**)&a1,m*sizeof(sfixn));
	  if(a1==NULL){
		  printf("karatsuba : a1\n");
		  exit(0);
	  }
	  cudaMalloc((void**)&b0,m*sizeof(sfixn));
	  if(b0==NULL){
		  printf("karatsuba : b0\n");
		  exit(0);
	  }	
	  cudaMalloc((void**)&b1,m*sizeof(sfixn));
	  if(a0==NULL){
		  printf("karatsuba : b1\n");
		  exit(0);
	  }
	  cudaMalloc((void**)&h0, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h0inv, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h2inv, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&suma, (m)*sizeof(sfixn));
	  cudaMalloc((void**)&sumb, (m)*sizeof(sfixn));
	  cudaMalloc((void**)&sum1, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&sum2, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h1, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h2, (2*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h1dec, (3*m-1)*sizeof(sfixn));
	  cudaMalloc((void**)&h2dec, (4*m-1)*sizeof(sfixn));
		karatsuba_gpu<<<size/1024,1024>>>(kar, h0,h0inv, h2inv, suma, sumb, sum1, sum2, h1, h2, h1dec, h2dec, a, b, a0, a1, b0, b1, size, p);
		cudaFree(a0);
	  cudaFree(a1);
	  cudaFree(b0);
	  cudaFree(b1);
    cudaFree(h0);
	  cudaFree(h1);
	  cudaFree(h2);
	  cudaFree(h1dec);
	  cudaFree(h2dec);
	  cudaFree(sum1);
	  cudaFree(sum2);
	  cudaFree(h2inv);
	  cudaFree(h0inv);
	  cudaFree(suma);
	 	cudaFree(sumb);
		
}
__global__ void karatsuba_gpu(sfixn* kar, sfixn* h0, sfixn* h0inv, sfixn* h2inv, sfixn* suma, sfixn* sumb, sfixn* sum1, sfixn* sum2, sfixn* h1, sfixn* h2, sfixn* h1dec, sfixn* h2dec,  sfixn* a, sfixn* b, sfixn* a0, 		sfixn* a1,sfixn* b0, sfixn* b1,sfixn size, sfixn p){
	karatsuba_rec(kar, h0,h0inv, h2inv, suma, sumb, sum1, sum2, h1, h2, h1dec, h2dec, a, b, a0, a1, b0, b1, size, p);
}



__device__ void karatsuba_rec(sfixn* kar, sfixn* h0, sfixn* h0inv, sfixn* h2inv, sfixn* suma, sfixn* sumb, sfixn* sum1, sfixn* sum2, sfixn* h1, sfixn* h2, sfixn* h1dec, sfixn* h2dec,  sfixn* a, sfixn* b, sfixn* a0, 		sfixn* a1,sfixn* b0, sfixn* b1,sfixn size, sfixn p){
	sfixn i,m;
	
	if(size==1){
		kar[0]=(a[0]*b[0])%p;
	}else{
	  m=size/2;
	  for(i=0;i<m;i++){
		  //printf("a[%d]=%d && b[q%d]=%d\n",i,a[i],i,b[i]);
		  a0[i]=a[i];	
		  b0[i]=b[i];
	  }
	  for(i=m;i<size;i++){
		  //printf("a[%d]=%d && b[%d]=%d\n",i,a[i],i,b[i]);
		  a1[i-m]=a[i];		
		  b1[i-m]=b[i];
	  }
	  karatsuba_rec(h0,a0,b0,m,p);
	  karatsuba_rec(h2,a1,b1,m,p);
	  somme_void(suma,a0,a1,m,m,p);
	  somme_void(sumb,b0,b1,m,m,p);
	  karatsuba_rec(h1,suma,sumb,m,p);
	  oppose_void(h0inv,h0,2*m-1,p);
	  oppose_void(h2inv,h2,2*m-1,p);
	  somme_void(sum1,h0inv,h2inv,2*m-1,2*m-1,p);
	  somme_void(h1,h1,sum1,2*m-1,2*m-1,p);
	  decalage_void(h1dec,h1,m,2*m-1);
	  decalage_void(h2dec,h2,2*m,2*m-1);
	  somme_void(sum2,h1dec,h2dec,2*m-1+m,4*m-1,p);
	  somme_void(kar,h0,sum2,2*m-1,2*m-1+2*m,p);
	  }
}
*/


__device__ void decalage_void(sfixn* dec, sfixn *tab, sfixn size, sfixn n){
	sfixn i;	
	for(i=0;i<size;i++){
		dec[i]=0;
	}
	for(i=size;i<size+n;i++){
		dec[i]=tab[i-size];
	}	
}

__device__ void somme_void(sfixn* sum, sfixn *a, sfixn *b, sfixn size_a, sfixn size_b, sfixn p){
	sfixn i;
	if(size_a>size_b){
		for(i=0;i<size_a;i++){
			if(i<size_b)
				sum[i]=(a[i]+b[i])%p;
			else 
				sum[i]=a[i];
		}

	}else{
		for(i=0;i<size_b;i++){
			if(i<size_a)
				sum[i]=(a[i]+b[i])%p;
			else 
				sum[i]=b[i];
		}
	}
}


__device__ void oppose_void(sfixn* op, sfixn* tab, sfixn size, sfixn p){
	sfixn i;
	int x,p1;
	p1=(int)p;
	for(i=0;i<size;i++){
	  x=(int)tab[i];
	  x=-x;
	  x=((x%p1)+p1)%p1;
	  
		op[i]=(unsigned int)x;
	}
}



// Fonction addition modulo MOD de polynomes sur Device (GPU)
__global__ void add_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn offset){
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
  sfixn r;
  if(ind+offset < size){
    r = a[ind+offset]+b[ind+offset];
		MOD_PERCENT(p,r);
		res[ind+offset] = r;
  }
}

// Fonction addition de polynomes sans modulo sur Device (GPU)
__global__ void add(sfixn* a, sfixn* b, sfixn* res, sfixn size, sfixn offset){
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;  //blockDim.x correspond au nombre de threads par block
  //printf("threadIdx.x = %d, blockIdx = %d, blockDim.x = %d, indice=%d\n",threadIdx.x,blockIdx.x,blockDim.x, ind);
  if(ind+offset < size){
    res[ind+offset]=a[ind+offset]+b[ind+offset];
  }   
}
__global__ void mult_mod_multhd_tmp(sfixn* a, sfixn* b, sfixn p, sfixn* tmp, sfixn cpt, sfixn divide, sfixn size){
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
  sfixn i,r;
  if(ind < divide){
	  for(i=0;i<size;i++){
	    r = (a[ind+(cpt-1)*divide]*b[i])%p;
	    //__syncthreads();
      tmp[i+ind*size]=r;
      //if(i==0 && ind==0) printf("r = %d, tmp[0] = %d\n",r,tmp[0]);
      //res[ind+i] += r;
      //MOD_PERCENT(p,res[ind+i]);
      //res[ind+i] = r;
    }
  }
}

/*
__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<2*size-1){
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}
			}
		}
	}
}
*/


/*
__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn max_uint){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<2*size-1){
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						if(res[i]>=max_uint)MOD_PERCENT(p,res[i]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						if(res[i]>=max_uint)MOD_PERCENT(p,res[i]);
					}
				}
				MOD_PERCENT(p,res[i]);
			}
		}
	}
}
*/

__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<=(2*(size-1))){
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						//MOD_PERCENT(p,r);
						res[i]+=r;
						//MOD_PERCENT(p,res[i]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						//MOD_PERCENT(p,r);
						res[i]+=r;
						//MOD_PERCENT(p,res[i]);
					}
				}
			}
		}
	}
}


__global__ void mult_mod_repart_iter(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn iter){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<=(2*(size-1))){
		sfixn i,j,k,r,nb_iter;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					sfixn decal=i-(size-1);
					nb_iter=(2*(size-1)-i)/iter;
					for(j=0;j<nb_iter;j++){
						for(k=j*iter+decal;k<(j+1)*iter+decal;k++){
							r=a[k]*b[i-k];
							res[i]+=r;
						}
						MOD_PERCENT(p,res[i]);
					}
					for(j=nb_iter*iter+decal;j<size;j++){
						r=a[j]*b[i-j];
						res[i]+=r;
					}
					MOD_PERCENT(p,res[i]);
				}else{
					nb_iter=i/iter;
					for(j=0;j<nb_iter;j++){
						for(k=j*iter;k<(j+1)*iter;k++){
							r=a[k]*b[i-k];
							res[i]+=r;
						}
						MOD_PERCENT(p,res[i]);
					}
					for(j=nb_iter*iter;j<=i;j++){
						r=a[j]*b[i-j];
						res[i]+=r;
					}
					MOD_PERCENT(p,res[i]);
				}
			}
		}
	}
}



__global__ void test(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T){	
	//sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
}



__global__ void mult_mod_repart_non_contigue(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn nb){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<=(2*(size-1)/T)){
		sfixn i,j,r;
		for(i=ind;i<=ind+nb*(T-1);i=i+nb){
			if(i==20000)
				printf("ind=%d\n",ind);
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}
			}
		}
	}
}

__global__ void mult_mod_repart_non_contigue2(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn nb){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	sfixn ind_offset=ind*T;
	if(ind<=(2*(size-1)/T)){
		sfixn i,j,r;
		for(i=ind;i<=ind+nb*(T-1);i=i+nb){
			if(i==20000)
				printf("ind=%d\n",ind);
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[ind_offset]+=r;
						MOD_PERCENT(p,res[ind_offset]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[ind_offset]+=r;
						MOD_PERCENT(p,res[ind_offset]);
					}
				}
			}
			ind_offset++;
		}
		
	}
}




__global__ void mult_mod_repart_depassement(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn max_uint, sfixn iter){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<2*size-1){
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					if(i>=iter){
						for(j=i-(size-1);j<size;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
							if(res[i]>=max_uint)MOD_PERCENT(p,res[i]);
						}
					}else{
						for(j=i-(size-1);j<size;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
						}
					}
				}else{
					if(i>=iter){
						for(j=0;j<=i;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
							if(res[i]>=max_uint)MOD_PERCENT(p,res[i]);
						}
					}else{
						for(j=0;j<=i;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
						}
					}
				}
				MOD_PERCENT(p,res[i]);
			}
		}
	}
}



/*
__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn T, sfixn max_iter){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<2*size-1){
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					if(i>=max_iter){
						for(j=i-(size-1);j<size;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
							MOD_PERCENT(p,res[i]);
							//if(k%(max_iter)==0 || j==size-1)MOD_PERCENT(p,res[i]);
							//k++;
						}
					}else{
						for(j=i-(size-1);j<size;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
							//MOD_PERCENT(p,res[i]);
							//if(k%(max_iter)==0 || j==size-1)MOD_PERCENT(p,res[i]);
							//k++;
						}
						MOD_PERCENT(p,res[i]);	
					}
					
				}else{
					if(i>=max_iter){
						//k=1;
						for(j=0;j<=i;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
							MOD_PERCENT(p,res[i]);
							//if(k==max_iter){
								//MOD_PERCENT(p,res[i]);
								//k=0;
							//}
							//k++;
						}
					}else{
						for(j=0;j<=i;j++){
							r=a[j]*b[i-j];
							MOD_PERCENT(p,r);
							res[i]+=r;
						}
						MOD_PERCENT(p,res[i]);
					}
					
				}
			}
		}
	}
}
*/
/*
__global__ void mult_mod_repart(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn nb_bloc){	
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	if(ind<2*size-1){
		sfixn T=(2*size-1)/(blockDim.x*nb_bloc);
		if((2*size-1)%blockDim.x!=0)
			T++;
		//printf("T=%d\n",T);
		sfixn i,j,r;
		for(i=ind*T;i<(ind+1)*T;i++){
			if(i<2*size-1){
				if(i>=size){
					for(j=i-(size-1);j<size;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}else{
					for(j=0;j<=i;j++){
						r=a[j]*b[i-j];
						MOD_PERCENT(p,r);
						res[i]+=r;
						MOD_PERCENT(p,res[i]);
					}
				}
			}
		}
	}
}
*/


__global__ void mult_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn i){
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
  sfixn r;
  printf("ind=%d\n",ind);
  if(ind < size){
    r = (a[ind]*b[i]);//%p;
    res[ind+i] += r;
    //MOD_PERCENT(p,res[ind+i]);
    //res[ind+i] = (res[ind+i]+(a[ind]*b[i]))%p;
  }
}


__global__ void mult_mod_share(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size){
  extern __shared__ sfixn selfres[];
  sfixn tid=threadIdx.x;
  //sfixn bid=size/blockIdx.x;
  //sfixn bid=blockIdx.x;
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
  sfixn i,r,j;
  //printf("TTTTTTTEEEEEEEEEEEETTTTTT\n");
  if(ind<size){
		for(i=0;i<size;i++){
			if(ind+i==1) printf("avant %d %d\n",selfres[i+ind]);
		  r = (a[ind]*b[i]);
		  __syncthreads();
		  selfres[ind+i]+=r;
		  if(i+ind==1) printf("apres %d %d\n",selfres[i+ind]);
		  //__syncthreads();
		}
		__syncthreads();
		if(tid==0){
			//__syncthreads();
		  for(j=0;j<2*size-1;j++){
		   	//__syncthreads();
		    res[j]=(res[j]+selfres[j]);
		    //__syncthreads();
		  }
		  //__syncthreads();
		}
	}
}

__global__ void mult_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size){
    sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
    sfixn i,r;
   
    if(ind < size){
        for(i=0;i<size;i++){
            r = (a[ind]*b[i]);//%p;
            __syncthreads();
            res[ind+i] = (res[ind+i]+r);//%p;
        }
    }
}





/*
sfixn i,r,q;
double ninv = 1 / (double)p;
q  = (sfixn) ((((double) a[ind]) * ((double) b[i])) * ninv);
            r = a[ind] * b[i] - q * p;   
            r += (r >> 31) & p;
            r -= p;
        r += (r >> 31) & p;
            r = (res[ind+i]+r);
            r = (res[ind+i]+r);   
            r-= p;
           r += (r >> 31) & p;
            res[ind+i] = r;   
*/


sfixn* multiplication_polynome_mod(sfixn* a, sfixn* b, sfixn p,sfixn size){
    sfixn*res;
    sfixn i,j,r;
    res =(sfixn*)malloc(2*size*sizeof(sfixn));
    memset(res, 0, 2*size*sizeof(sfixn));
    for(i=0;i<size;i++){
        for(j=0;j<size;j++){
            r=(a[i]*b[j]);
            MOD_PERCENT(p,r); 
            r+=res[i+j];
            MOD_PERCENT(p,r);
            res[i+j]=r;
        }           
    }
    return res;
}


__global__ void mult_mod_multhd2(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn i, sfixn op_thread){
  sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
  ind=ind*op_thread;
  sfixn j,r;
  if(ind<size){
		for(j=0;j<op_thread;j++){
		  if(ind+i+j <= 2*(size-1) && ind+j<size){
		    r = (a[ind+j]*b[i])%p;
		    r += res[ind+i+j];
		    MOD_PERCENT(p,r);
		    res[ind+i+j] = r;
		  }
		}
	}
}
/*__global__ void mult_mod(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn i){
	sfixn ind=threadIdx.x+blockIdx.x*blockDim.x;
	sfixn r;
	if(ind < size){
		r = (a[ind]*b[i])%p;
		res[ind+i] = (res[ind+i]+r)%p;
		//res[ind+i] = (res[ind+i]+(a[ind]*b[i]))%p;
	}
}*/


// Fonction addition modulo MOD de polynomes sur Device (GPU) avec multiples opérations par thread
__global__ void add_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn offset, sfixn op_thread){
  sfixn i,r;
  sfixn ind=op_thread*threadIdx.x+blockIdx.x*blockDim.x*op_thread;  //blockDim.x correspond au nombre de threads par block
  for(i=0;i<op_thread;i++){
    if(ind+offset+i < size){
      r = a[ind+offset+i]+b[ind+offset+i];
      MOD_PERCENT(p,r);
      res[ind+offset+i]=r;
    }
  } 
}

__global__ void mult_tat_mod_multhd(sfixn* a, sfixn* b, sfixn p, sfixn* res, sfixn size, sfixn offset, sfixn op_thread){
  sfixn i;
  sfixn ind=op_thread*threadIdx.x+blockIdx.x*blockDim.x*op_thread;  //blockDim.x correspond au nombre de threads par block
  for(i=0;i<op_thread;i++){
    if(ind+offset+i < size){
      res[ind+offset+i]=(a[ind+offset+i]*b[ind+offset+i])%p;
      if(ind+offset+i == size-1){
        printf("res=%d\n",res[ind+offset+i]);
      }
    }
  } 
}
