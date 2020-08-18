#include <iocsh.h>
#include <epicsExport.h>

#include "cpswStreamBSA.h"
#include "blenBSA.h"
#include "blenFcom.h"

/*
 * blenConfigureMR
 * 
 * Args:
 * Station Name (station):    The name of the installation. Eg: BLEN:LI24:887
 * BSA stream name (stream):  Must be identical to YAML definition
 * FCOM TMIT PV (tmit):       PV name of source of TMIT data
 * ATCA IP:PORT (atcaIP):     IP:PORT in 32 bit ipv4 format to send TMIT to FPGA
 *
 */ 

static const iocshArg blenConfigureMRArg0 = { "Station name", iocshArgString };
static const iocshArg blenConfigureMRArg1 = { "BSA stream name", iocshArgString };
static const iocshArg blenConfigureMRArg2 = { "FCOM TMIT PV", iocshArgString };
static const iocshArg blenConfigureMRArg3 = { "ATCA IP:port to send TMIT", iocshArgString };

static const iocshArg * const blenConfigureMRArgs[] = { 
        &blenConfigureMRArg0,
        &blenConfigureMRArg1, 
        &blenConfigureMRArg2,
        &blenConfigureMRArg3
};
static const iocshFuncDef blenConfigureMRFuncDef = { "blenConfigureMR", 4, blenConfigureMRArgs };

static int
blenConfigureMR(const char *station, const char *stream, const char *tmit, const char *atcaIP)
{
    auto blenBSA = BlenBSA::getInstance();
    blenBSA->createChannels(station);

    auto streamBSA = CpswStreamBSA::getInstance();
    streamBSA->setStreamName(stream);
    streamBSA->fireStreamTask();

    auto blenFcom = BlenFcom::getInstance();
    blenFcom->registerTmitId(tmit);
    
    /* ARAW PV is, for example, BLEN:LI21:265:ARAW. station parameter comes
     * as BLEN:LI21:265.
     */
    auto aRawPv = std::string { station }.append(":ARAW");
    blenFcom->registerArawId(aRawPv);
    blenFcom->registerAtcaIpToSendTMIT(atcaIP);
    blenFcom->fireFcomTask();

    return 0;
}

static void
blenConfigureMRCallFunc(const iocshArgBuf * args)
{
    blenConfigureMR(args[0].sval, args[1].sval, args[2].sval, args[3].sval);
}

static const iocshFuncDef blenReportMRFuncDef = { "blenReportMR", 0, nullptr };

static int
blenReportMR(void)
{
    const auto& blenStats = BlenFcom::getInstance()->getStats();

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

static void blenReportMRCallFunc(const iocshArgBuf * args)
{
    blenReportMR();
}

/******************************************************************************
 * Dump BSA Stream print the stream to the console in groups of 4 bytes, using
 * the hexadecimal format.
 *
 * Input: number of packets. This is the number of sequential packets that will
 * be dumped.
******************************************************************************/

static const iocshArg blenDumpBSAStreamMRArg0 = { "Number of packets to print", iocshArgInt };
static const iocshArg *const blenDumpBSAStreamMRArgs[] = { &blenDumpBSAStreamMRArg0 };
static const iocshFuncDef blenDumpBSAStreamMRFuncDef = { "blenDumpBSAStreamMR", 1, blenDumpBSAStreamMRArgs };

void 
blenDumpBSAStreamMR(int numberOfPackets)
{
    // Get instance of the stream BSA class
    auto streamBSA = CpswStreamBSA::getInstance();
    streamBSA->setNumberPacketsToDump(numberOfPackets);
}

static void blenDumpBSAStreamMRCallFunc(const iocshArgBuf * args)
{
    blenDumpBSAStreamMR(args[0].ival);
}


void BlenIOCFunctionsRegistrar(void)
{
    iocshRegister(&blenConfigureMRFuncDef, blenConfigureMRCallFunc);
    iocshRegister(&blenReportMRFuncDef, blenReportMRCallFunc);
    iocshRegister(&blenDumpBSAStreamMRFuncDef, blenDumpBSAStreamMRCallFunc);
}

epicsExportRegistrar(BlenIOCFunctionsRegistrar);
