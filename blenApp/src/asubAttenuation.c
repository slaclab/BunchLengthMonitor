#include <aSubRecord.h>
#include <epicsExport.h>
#include <registryFunction.h>

static long GetAttenuationIndex(aSubRecord *);
static int  check_flt_sts(long);

epicsRegisterFunction(GetAttenuationIndex);

/**
 * The LCLS-II pyrodetector has 4 insertable filters. For each of the 16
 * possible arrangements of those filters, there is an attenuation value in the
 * firmware. This routine determines which of the 16 attenuation values should
 * be used based on the current filter configuration.
 *
 * Each of the inputs A, B, C, D into this record should be Filters 1, 2, 3, 4
 * status bits.
 *
 * We're using an aSub since it has documented support for setting field types.
 * Subroutine record types might also have that feature but it's not in the RRM.
 */
static long
GetAttenuationIndex(aSubRecord *precord)
{
    // Skip if any of the inputs are MOVING (0x2) or INCONSISTENT (0x3)
    if ( check_flt_sts((long)precord->a) || check_flt_sts((long)precord->b) ||
         check_flt_sts((long)precord->c) || check_flt_sts((long)precord->d) )
       return 0; 

    /*
     * Ok, so we should now put a value between 0-15 in the VAL field
     * depending on which permutation of the filters are inserted.
     *
     * We have a 4 bit number where 0b0000 = all filters out (0) and 
     * 0b1111 = all filters in (15).
     * bits 0-3 correspond to filters 1-4.
     */
    precord->vala = 0;
    precord->vala = (void *)(
                    ( (long)precord->a << 0 ) |
                    ( (long)precord->b << 1 ) |
                    ( (long)precord->c << 2 ) |
                    ( (long)precord->d << 3 ) );

    return 0;
}


/*
 * Checks if a filter is either MOVING (0x2) or INCONSISTENT (0x3).
 *
 * Returns 0 if filter is neither moving nor inconsistent, 0 otherwise
 */
static int
check_flt_sts(long value)
{
    if ( (value & 0x2) != 0 )
        return 1;

    return 0;
}

