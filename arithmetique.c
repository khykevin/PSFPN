#include <stdio.h>
#include <stdlib.h>
#include "sys/time.h"
#include "time.h"
#include "string.h"

#define DEG 500000000

/* CPU1: Intel(R) Xeon(R) CPU E3-1275 v3 @ 3.50GHz
CPU2: Intel(R) Xeon(R) CPU E5-2660 0 @ 2.20GHz
CPU3: Intel(R) Xeon(R) CPU E5-2695 v4 @ 2.10GHz
305: Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz
*/


typedef unsigned int sfixn;

sfixn BASE_1 = 31;

/* Fonction d'affichage des coefficients d'un polynôme */

void affichage_polynome(sfixn *res){
    sfixn i;
    for(i=DEG-10;i<DEG;i++){
    	printf("P[%d]=%d  \n",i,res[i]);
    }
    printf("\n");
}

sfixn mul_mod(sfixn a, sfixn b, sfixn n) {
    double ninv = 1 / (double)n;//(double)1/n
    printf("ninv=%lf\n",ninv);
    sfixn q  = (sfixn) ((((double) a) * ((double) b)) * ninv);
    printf("q=%d\n",q);
    sfixn res = a * b - q * n;
    printf("res=%d\n",res);
    res += (res >> BASE_1) & n;
    printf("res=%d\n",res);
    res -= n;
    printf("res=%d\n",res);
    res += (res >> BASE_1) & n;
    return res;
}

/* Additionne deux polynômes a et b modulo p */
sfixn* addition_polynome_mod(sfixn* a, sfixn* b, sfixn p){
    sfixn*res,i;
    //sfixn r;
    res = malloc(DEG*sizeof(sfixn));
    for(i=0;i<DEG;i++){
        res[i] =(a[i]+b[i])%p;
    /*    r-= p;
           r += (r >> BASE_1) & p;
        res[i]=r;
        res[i] = (a[i] + b[i])%p;*/
        //if(r >= p) res[i] = r-p;
        //printf("add[%d]=%d ",i,res[i]);           
    }
    return res;
}

sfixn* addition_polynome(sfixn* a, sfixn* b){
    sfixn*res,i;
    res = malloc(DEG*sizeof(sfixn));
    for(i=0;i<DEG;i++){
        res[i] =(a[i]+b[i]);           
    }
    return res;
}

sfixn* mult_tat_polynome_mod(sfixn* a, sfixn* b, sfixn p){
    sfixn*res,i;
    res = malloc(DEG*sizeof(sfixn));
    for(i=0;i<DEG;i++){
        res[i] =(a[i]*b[i])%p;
    }
    return res;
}

// GPU1, DEG = 100000 : 2.80s DEG = 1M : 353s
sfixn* multiplication_polynome_mod(sfixn* a, sfixn* b, sfixn p){
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
    sfixn *a,*b,*res,p,size,i;
    clock_t end;
    double time_spent;
    size = DEG*sizeof(sfixn);   
    a = (sfixn*)malloc(size);
    b = (sfixn*)malloc(size);
    //debut=my_gettimeofday();/*Temps début d'execution*/
    //int testmod=mul_mod(5, 2, 7);
    //printf("testmod=%d\n",testmod);    
    p=65521;
    srand(time(NULL));
    /* On initialise les coefficients de polynomes de degre DEG */
    for(i=0; i<DEG; i++){
        a[i]=(sfixn) (p*((double)rand())/ RAND_MAX);
        b[i]=(sfixn) (p*((double)rand())/ RAND_MAX);
        
        //printf("a[%d]=%d et b[%d]=%d\n",i,a[i],i,b[i]);
    }
    printf("%d\n",(a[DEG-1]+b[DEG-1])%p);
		res=addition_polynome_mod(a,b,p);
    //res = multiplication_polynome_mod(a,b,p);
    printf("%d\n",res[DEG-1]);
    end = clock();
    time_spent = (double)(end) / CLOCKS_PER_SEC;
    printf("Le temps d'execution est de : %g\n",time_spent);
    //affichage_polynome(res);
    /*for(i=0;i<DEG;i++){
    	if(res[i]!=(a[i]+b[i])%p)
    		printf("ERREUR %d res=%d bon=%d\n",i,res[i],(a[i]+b[i])%p);
    }*/
    
    free(a);
    free(b);
    free(res);
    return 0;
}


