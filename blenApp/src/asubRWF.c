#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>

static long calcRWF16(aSubRecord *pasub) {
    /*
     * Calculate an unsiged 16 bit array from a signed array.
     * The raw 16 bit stream data is encoded unsigned but the asyn port driver converts it to signed.
     * This routine eliminates the sign bit with the side effet of halving the sampled value.
     */
    short i;
    pasub->pact = 1;

    for (i = 0; i < pasub->noa; i++) {
        /* the casts are necessary to first convert from void * and then to do our conversion from signed to
         * unsigned and back to the signed SHORT the record is expecting */
        ((short *)pasub->vala)[i] = (short)(((unsigned short *)pasub->a)[i] >> 1);
    }

    pasub->pact = 0;

    return 0; /* process output links */
}

epicsRegisterFunction(calcRWF16);
