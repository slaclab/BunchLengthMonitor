#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>

static long calcTimeArray(aSubRecord *pasub) {
    long i;
    double clkFreq, sum = 0.0, timeNs;

    clkFreq = (double)(*(long *)pasub->a);

    /* Calculate the time in ns between each sample */
    timeNs = 1000000000.0 / (2.0 * clkFreq);

    /* Then make an array with each element a distance of `timeNs` apart */
    for (i = 0; i < pasub->nova; i++) {
        ((double *)pasub->vala)[i] = sum;
        sum += timeNs;
    }


    return 0; /* process output links */
}

epicsRegisterFunction(calcTimeArray);
