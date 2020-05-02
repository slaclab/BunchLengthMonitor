#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>

static long calcTimeArray(aSubRecord *pasub) {
    long i, *clkFreq;
    double sum = 0, timeNs;

    pasub->pact = 1;

    clkFreq = (long *)pasub->a;

    // Calculate the time in ns between each sample, giving the clock
    // frequency in Hertz
    timeNs = 1000000000 / (2.0 * *clkFreq);

    // Build array with the relative time for each sample since the first one
    for (i=0; i < pasub->nova; ++i) {
        ((double *)pasub->vala)[i] = sum;
        sum += timeNs;
    }

    pasub->pact = 0;

    return 0; /* process output links */
}

epicsRegisterFunction(calcTimeArray);
