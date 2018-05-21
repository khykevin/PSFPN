#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "sys/time.h"
#include "time.h"
#include "stdint.h"
#define DEG 65536
#define MOD 65521
#define TEST 1
 
typedef unsigned int sfixn;
/*


Avec mod et O3

Karatsuba void: 
DEG = 1024   0.0123
DEG = 2048   0.035
DEG = 4096   0.104
DEG = 8192   0.311
DEG = 16384  0.93
DEG = 32768  2.798
DEG = 65535  8.39
DEG = 131071 27.2
DEG = 262143 87.34


Naive :
DEG = 1024   0.006
DEG = 2048   0.023
DEG = 4096   0.094
DEG = 8192   0.37
DEG = 16384  1.47
DEG = 32768  5.83
DEG = 65535  22.62
DEG = 131071 90.45


*/
int mod(int a,int n) {
  int res;
  if(a<0)
    res=((a%n)+n)%n;
  else  
    res=a%n;
  return res;
}


void mod_void(int a,int n) {
  if(a<0)
    a=((a%n)+n)%n;
  else  
    a=a%n;
}

void affiche_polynome(sfixn* tab, sfixn size){
	sfixn i;
	for(i=0;i<size;i++){
		printf("pol[%d]=%d\n",i,tab[i]);
	}
}

sfixn* decalage(sfixn *tab, sfixn size, sfixn n){
	//sizeof((size+n)*sizeof(sfixn)
	sfixn* tmp=(sfixn*)malloc((size+n)*sizeof(sfixn));
	if(tmp==NULL){
		printf("decalage : tmp\n");
		exit(0);
	}
	sfixn i;	
	for(i=0;i<size;i++){
		tmp[i]=0;
	}
	for(i=size;i<size+n;i++){
		tmp[i]=tab[i-size];
	}	
	
	return tmp;
}


void decalage_void(sfixn* dec, sfixn *tab, sfixn size, sfixn n){
	sfixn i;	
	for(i=0;i<size;i++){
		dec[i]=0;
	}
	for(i=size;i<size+n;i++){
		dec[i]=tab[i-size];
	}	
}


sfixn* somme(sfixn *a, sfixn *b, sfixn size_a, sfixn size_b, sfixn p){
	sfixn i;
	sfixn *res;	
	if(size_a>size_b){
		res=(sfixn*)malloc(size_a*sizeof(sfixn));
		if(res==NULL){
			printf("somme : res size_a>size_b\n");
			exit(0);
		}	
		for(i=0;i<size_a;i++){
			if(i<size_b)
				res[i]=(a[i]+b[i])%p;
			else 
				res[i]=a[i];
		}

	}else{
		res=(sfixn*)malloc(size_b*sizeof(sfixn));
		if(res==NULL){
			printf("somme : res else\n");
			exit(0);
		}
		for(i=0;i<size_b;i++){
			if(i<size_a)
				res[i]=(a[i]+b[i])%p;
			else 
				res[i]=b[i];
		}
	}
	return res;
}

void somme_void(sfixn* sum, sfixn *a, sfixn *b, sfixn size_a, sfixn size_b, sfixn p){
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


sfixn* oppose(sfixn* tab, sfixn size, sfixn p){
	sfixn i;
	sfixn* tmp=malloc(size*sizeof(sfixn));
	int x;
	if(tmp==NULL){
		printf("oppose : tmp\n");
		exit(0);
	}	
	for(i=0;i<size;i++){
	  x=(int)tab[i];
	  x=-x;
	  x=mod(x,p);
		tmp[i]=(unsigned int)x;
	}
	return tmp;
}

void oppose_void(sfixn* op, sfixn* tab, sfixn size, sfixn p){
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


sfixn* karatsuba(sfixn* a,sfixn* b, sfixn size, sfixn p){
	sfixn i,m;
	sfixn *a0;
	sfixn *a1;
	sfixn *b0;
	sfixn *b1;
	sfixn* h0;
	sfixn* h1;
	sfixn* h2;
	if(size==1){
		sfixn* res;
		res=malloc(sizeof(sfixn));
		res[0]=(a[0]*b[0])%p;
		return res;
	}	
	m=size/2;
	a0=malloc(m*sizeof(sfixn));
	if(a0==NULL){
		printf("karatsuba : a0\n");
		exit(0);
	}
	a1=malloc(m*sizeof(sfixn));
	if(a1==NULL){
		printf("karatsuba : a1\n");
		exit(0);
	}
	b0=malloc(m*sizeof(sfixn));
	if(b0==NULL){
		printf("karatsuba : b0\n");
		exit(0);
	}	
	b1=malloc(m*sizeof(sfixn));
	if(a0==NULL){
		printf("karatsuba : b1\n");
		exit(0);
	}
	sfixn *sum1;
	sfixn *sum2;
	sfixn *res;
	sfixn *h0inv;
	sfixn *h2inv;
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
	h0=karatsuba(a0,b0,m,p);
	h2=karatsuba(a1,b1,m,p);
	h1=karatsuba(somme(a0,a1,m,m,p),somme(b0,b1,m,m,p),m,p);
	h0inv=oppose(h0,2*m-1,p);
	h2inv=oppose(h2,2*m-1,p);
	sum1=somme(h0inv,h2inv,2*m-1,2*m-1,p);
	h1=somme(h1,sum1,2*m-1,2*m-1,p);
	h1=decalage(h1,m,2*m-1);
	h2=decalage(h2,2*m,2*m-1);
	sum2=somme(h1,h2,2*m-1+m,4*m-1,p);
	res= somme(h0,sum2,2*m-1,2*m-1+2*m,p);
	/*free(a0);
	free(a1);
	free(b0);
	free(b1);
  free(h0);
	free(h1);
	free(h2);
	free(sum1);
	free(sum2);*/
	return res;
}

void karatsuba_void(sfixn* kar, sfixn* a,sfixn* b, sfixn size, sfixn p){
	sfixn i,m;
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
	if(size==1){
		kar[0]=(a[0]*b[0])%p;
	}else{
	  m=size/2;
	  a0=malloc(m*sizeof(sfixn));
	  if(a0==NULL){
		  printf("karatsuba : a0\n");
		  exit(0);
	  }
	  a1=malloc(m*sizeof(sfixn));
	  if(a1==NULL){
		  printf("karatsuba : a1\n");
		  exit(0);
	  }
	  b0=malloc(m*sizeof(sfixn));
	  if(b0==NULL){
		  printf("karatsuba : b0\n");
		  exit(0);
	  }	
	  b1=malloc(m*sizeof(sfixn));
	  if(a0==NULL){
		  printf("karatsuba : b1\n");
		  exit(0);
	  }
	  h0=malloc((2*m-1)*sizeof(sfixn));
	  h0inv=malloc((2*m-1)*sizeof(sfixn));
	  h2inv=malloc((2*m-1)*sizeof(sfixn));
	  suma=malloc((m)*sizeof(sfixn));
	  sumb=malloc((m)*sizeof(sfixn));
	  sum1=malloc((2*m-1)*sizeof(sfixn));
	  sum2=malloc((4*m-1)*sizeof(sfixn));
	  h1=malloc((2*m-1)*sizeof(sfixn));
	  h2=malloc((2*m-1)*sizeof(sfixn));
	  h1dec=malloc((3*m-1)*sizeof(sfixn));
	  h2dec=malloc((4*m-1)*sizeof(sfixn));
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
	  karatsuba_void(h0,a0,b0,m,p);
	  karatsuba_void(h2,a1,b1,m,p);
	  somme_void(suma,a0,a1,m,m,p);
	  somme_void(sumb,b0,b1,m,m,p);
	  karatsuba_void(h1,suma,sumb,m,p);
	  oppose_void(h0inv,h0,2*m-1,p);
	  oppose_void(h2inv,h2,2*m-1,p);
	  somme_void(sum1,h0inv,h2inv,2*m-1,2*m-1,p);
	  somme_void(h1,h1,sum1,2*m-1,2*m-1,p);
	  decalage_void(h1dec,h1,m,2*m-1);
	  decalage_void(h2dec,h2,2*m,2*m-1);
	  somme_void(sum2,h1dec,h2dec,2*m-1+m,4*m-1,p);
	  somme_void(kar,h0,sum2,2*m-1,2*m-1+2*m,p);
	  free(a0);
	  free(a1);
	  free(b0);
	  free(b1);
    free(h0);
    free(h0inv);
	  free(h1);
	  free(h2);
	  free(h2inv);
	  free(h1dec);
	  free(h2dec);
	  free(sum1);
	  free(sum2);
	  free(suma);
	  free(sumb);
	  }
}


sfixn* multiplication_polynome(sfixn* a, sfixn* b, sfixn deg){
	sfixn *res;
	sfixn i,j;
	res = malloc((2*DEG-1)*sizeof(sfixn));
	if(res==NULL){
		printf("multiplication polynome naive : res\n");
		exit(0);
	}
	memset(res, 0, (2*DEG-1)*sizeof(sfixn));
	for(i=0;i<DEG;i++){
	    for(j=0;j<DEG;j++){
    	  res[i+j] = res[i+j]+(a[i]*b[j]);
        	//res[i+j] = (res[i+j]+(a[i]*b[j])%p)%p;
        	//printf("a[%d]=%d b[%d]=%d et res[%d]=%d\n",i,a[i],j,b[j],i+j,res[i+j]);
    	}           
	}
	return res;
}

sfixn* multiplication_polynome_mod(sfixn* a, sfixn* b, sfixn deg, sfixn p){
	sfixn* res;
	sfixn i,j;
	res = malloc((2*DEG-1)*sizeof(sfixn));
	if(res==NULL){
		printf("multiplication polynome naive : res\n");
		exit(0);
	}
	memset(res, 0, (2*DEG-1)*sizeof(sfixn));
	for(i=0;i<DEG;i++){
	    for(j=0;j<DEG;j++){
    	  //res[i+j] = mod(res[i+j]+mod(a[i]*b[j],p),p);
        res[i+j] = (res[i+j]+(a[i]*b[j])%p)%p;
        	//printf("a[%d]=%d b[%d]=%d et res[%d]=%d\n",i,a[i],j,b[j],i+j,res[i+j]);
    	}           
	}
	return res;
}

sfixn* multiplication_polynome_mod2(sfixn* a, sfixn* b, sfixn p){
    sfixn*res,i,j;
    res = malloc((2*DEG-1)*sizeof(sfixn));
    memset(res, 0, (2*DEG-1)*sizeof(sfixn));
    for(i=0;i<DEG;i++){
        for(j=0;j<DEG;j++){
            res[i+j] = (res[i+j]+(a[i]*b[j])%p)%p;
            //printf("a[%d]=%d b[%d]=%d et res[%d]=%d\n",i,a[i],j,b[j],i+j,res[i+j]);
        }           
    }
    return res;
}


int main(){
	/*sfixn a[DEG]={1,2,3,4};
	sfixn b[DEG]={1,2,3,4};*/
	
	
	sfixn* kar=malloc((2*DEG-1)*sizeof(sfixn));
	unsigned int* naive;
	sfixn* a=malloc(DEG*sizeof(sfixn));
	if(a==NULL){
		printf("main : a\n");
		exit(0);
	}
	sfixn* b=malloc(DEG*sizeof(sfixn));
	if(b==NULL){
		printf("main : b\n");
		exit(0);
	}	
	sfixn i;
	srand(time(NULL));
	for(i=0;i<DEG;i++){
		 a[i]=(sfixn) (MOD*((double)rand())/ RAND_MAX);
     b[i]=(sfixn) (MOD*((double)rand())/ RAND_MAX);
	}
	//kar=karatsuba(a,b,DEG,MOD);
	clock_t temps;
	karatsuba_void(kar,a,b,DEG,MOD);
	naive=multiplication_polynome_mod(a,b,DEG,MOD);
	temps=clock();
	printf("Le temps d'execution est de : %f\n",(double)temps/CLOCKS_PER_SEC);
	//naive=multiplication_polynome(a,b,DEG);
	/*affiche_polynome(kar,2*DEG-1);*/
	if(TEST){
		for(i=0;i<2*DEG-1;i++){
			if(kar[i]!=naive[i])
				printf("ERREUR kar[%d]=%d && naive[%d]=%d\n",i,kar[i],i,naive[i]);

		}
	}
	free(a);
	free(b);
	free(kar);
	free(naive);
	
	
	return 0;
}	
