#include <iocsh.h>
#include <epicsExport.h>

#include "cpswStreamBSA.h"
#include "blenBSA.h"
#include "blenFcom.h"

static int blenConfigure(const char *stationName, 
                         const char *streamName,
                         const char *tmitPvName,
                         const char *atcaIpToSendTMIT) {
    // Create and configure object responsible to send BSA data.
    class BlenBSA* pBlenBSA;
    pBlenBSA = BlenBSA::getInstance();
    pBlenBSA->createChannels(stationName);

    // Create and configure object responsible for monitoring the arrival of
    // BSA stream message and parsing it.
    class CpswStreamBSA* pStreamBSA;
    pStreamBSA = CpswStreamBSA::getInstance();
    pStreamBSA->setStreamName(streamName);
    // Fire the thread that will take care of the message receiving
    pStreamBSA->fireStreamTask();

    
    // Create and configure object responsible to deal with FCOM messages
    class BlenFcom* pBlenFcom;
    pBlenFcom = BlenFcom::getInstance();
    pBlenFcom->registerTmitId(tmitPvName);
    // ARAW PV is, for example, BLEN:LI21:265:ARAW. stationName parameter comes
    // as BLEN:LI21:265.
    std::string aRawPv(stationName);
    aRawPv += ":ARAW";
    pBlenFcom->registerArawId(aRawPv);
    pBlenFcom->registerAtcaIpToSendTMIT(atcaIpToSendTMIT);
    pBlenFcom->fireFcomTask();

    return 0;
}

/* epics ioc shell command for blenConfigure */

static const iocshArg blenConfigureArg0 = { "Station name", iocshArgString };
static const iocshArg blenConfigureArg1 = {"BSA stream name", iocshArgString};
static const iocshArg blenConfigureArg2 = {"FCOM TMIT PV", iocshArgString};
static const iocshArg blenConfigureArg3 = 
                                {"ATCA IP:port to send TMIT", iocshArgString};
static const iocshArg * const blenConfigureArgs[] = 
                    { &blenConfigureArg0, &blenConfigureArg1, 
                      &blenConfigureArg2, &blenConfigureArg3 };
static const iocshFuncDef blenConfigureFuncDef = 
                    { "blenConfigure", 4, blenConfigureArgs };
static void blenConfigureCallFunc(const iocshArgBuf * args)
{
    blenConfigure(args[0].sval, args[1].sval, args[2].sval, args[3].sval);
}

static int blenReport() {
    struct tBlenStats blenStats;
    class BlenFcom* pBlenFcom;

    pBlenFcom = BlenFcom::getInstance();

    blenStats = pBlenFcom->getStats();

    printf("------- FCOM report -------\n");
    printf("\n-- Rx --\n");
    printf("# FCOM messages received with success: %d\n", blenStats.fcomProcessed);
    printf("# timeouts: %d\n", blenStats.fcomTimeouts);
    printf("# FCOM messages arriving with error: %d\n", blenStats.fcomErrors);
    printf("# FCOM messages with message status error: %d\n", blenStats.fcomStatErrors);

    printf("\n-- Tx --\n");
    printf("# FCOM messages transmitted with success: %d\n", blenStats.fcomTransmitted);
    printf("# errors when transmiting FCOM messages: %d\n", blenStats.fcomTxError);
   
    printf("\n-- General Data --\n");

    if (blenStats.fcomInvalidAtcaIp || blenStats.fcomInvalidAtcaIpPort) {
        printf("There is a problem with the ATCA card IP address or port number informed in function blenConfigure.\n");
    }

    if (blenStats.cannotCreateSocket) {
        printf("There is a problem when creating a socket to send TMIT to the ATCA card.\n");
    }

    if (blenStats.sendToFailed) {
        printf("There is a problem when sending TMIT to the ATCA card.\n");
    }

    printf("Last TMIT = %f\n", blenStats.lastTmit);
    printf("Last X = %f\n", blenStats.lastX);
    printf("Last Y = %f\n", blenStats.lastY);
    printf("Last transmitted aimax = %f\n", blenStats.lastAimaxSent);
    printf("Last transmitted bimax = %f\n", blenStats.lastBimaxSent);
    printf("Last timestamp high = %d\n", blenStats.lastTimeStampHi);
    printf("Last timestamp low = %d\n", blenStats.lastTimeStampLo);
    // Pulse ID is loaded in the last 17 bits of timestamp low
    printf("Pulse ID = %d\n", blenStats.lastTimeStampLo & 0x1FFFF);

    return 0;
}

/* epics ioc shell command for blenReport */

static const iocshArg * const blenReportArgs[] = {};
static const iocshFuncDef blenReportFuncDef =
                    { "blenReport", 0, blenReportArgs };
static void blenReportCallFunc(const iocshArgBuf * args)
{
    blenReport();
}

/******************************************************************************
 * Dump BSA Stream print the stream to the console in groups of 4 bytes, using
 * the hexadecimal format.
 *
 * Input: number of packets. This is the number of sequential packets that will
 * be dumped.
******************************************************************************/
void blen_dumpBSAStream(int numberOfPackets)
{
    // Get instance of the stream BSA class
    class CpswStreamBSA* pStreamBSA;
    pStreamBSA = CpswStreamBSA::getInstance();
    pStreamBSA->setNumberPacketsToDump(numberOfPackets);
}

static const iocshArg blen_dumpBSAStreamArg0 = { "Number of packets to print",
                                                iocshArgInt };
static const iocshArg *const blen_dumpBSAStreamArgs[] = {&blen_dumpBSAStreamArg0};
static const iocshFuncDef blen_dumpBSAStreamFuncDef = {"blen_dumpBSAStream", 1,
                                                       blen_dumpBSAStreamArgs };

static void blen_dumpBSAStreamCallFunc(const iocshArgBuf * args)
{
    blen_dumpBSAStream(args[0].ival);
}



void BlenIOCFunctionsRegistrar(void)
{
    iocshRegister(&blenConfigureFuncDef, blenConfigureCallFunc);
    iocshRegister(&blenReportFuncDef, blenReportCallFunc);
    iocshRegister(&blen_dumpBSAStreamFuncDef, blen_dumpBSAStreamCallFunc);
}

epicsExportRegistrar(BlenIOCFunctionsRegistrar);
