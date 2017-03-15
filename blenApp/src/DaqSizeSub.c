#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
 
#include <dbEvent.h>
#include <dbDefs.h>
#include <dbCommon.h>
#include <registryFunction.h>
#include <aSubRecord.h>
#include <epicsExport.h>
#include <recSup.h>
#include <string.h>
 
static long DaqSizeSub(aSubRecord *prec)
{
	int i;
	size_t nelm_bay0 = prec->noc;
	size_t nelm_bay1 = prec->nod;
	int *size_bay0 = (int*)prec->a;
	int *size_bay1 = (int*)prec->b;
	int *startAddr_bay0 = (int*)prec->c;
	int *startAddr_bay1 = (int*)prec->d;


	int *endAddr_bay0 = (int*)malloc(nelm_bay0*sizeof(int));
	int *endAddr_bay1 = (int*)malloc(nelm_bay1*sizeof(int));

	for (i = 0; i < nelm_bay0 ; i++)
		*(endAddr_bay0 + i) =  *(startAddr_bay0 + i) + 4*(*size_bay0);

	for (i = 0; i < nelm_bay1 ; i++)
		*(endAddr_bay1 + i) =  *(startAddr_bay1 + i) + 4*(*size_bay1);

	memcpy(prec->vala, size_bay0, sizeof(int)); 
	memcpy(prec->valb, size_bay1, sizeof(int)); 
	memcpy(prec->valc, endAddr_bay0, nelm_bay0*sizeof(int)); 
	memcpy(prec->vald, endAddr_bay1, nelm_bay1*sizeof(int)); 

	return(0);
}
 
epicsRegisterFunction(DaqSizeSub);
