#include <string.h>
// *** For sending TMIT to the ATCA by opening UDP connection
#include <arpa/inet.h>
#include <cstdlib>
#include <iostream>
#include <netdb.h>
#include <unistd.h>
// ***

#include <epicsThread.h>
#include <errlog.h>
#include <alarm.h>
#include <fcom_api.h>
#include <fcomLclsBpm.h>
#include <fcomLclsBlen.h>

#include "blenFcom.h"

// More than 8.3 ms means we effectively lost the TMIT arrival
volatile unsigned blmFcomTimeoutMs = 9;

// Singleton design pattern: initialize class instance pointer to null.
BlenFcom* BlenFcom::instance = 0;

// Get the instance pointer for the class. If it is the first time,
// create a new one.
BlenFcom* BlenFcom::getInstance() {
    if (instance == 0) {
        instance = new BlenFcom();
    }

    return instance;
}

// C wrapper to call class method
static void C_fcomTask(void *p) {
    BlenFcom* pBlenFcom = BlenFcom::getInstance();
    pBlenFcom->fcomTask();
}

BlenFcom::BlenFcom() {
    // Initialize statistical variables
    blenStats.lastTmit = 0;
    blenStats.lastX = 0;
    blenStats.lastY = 0;
    blenStats.lastTimeStampHi = 0;
    blenStats.lastTimeStampLo = 0;
    blenStats.fcomTimeouts = 0;
    blenStats.fcomErrors = 0;
    blenStats.fcomStatErrors = 0;
    blenStats.fcomProcessed = 0;
    blenStats.fcomTransmitted = 0;
    blenStats.fcomTxError = 0;
    blenStats.fcomInvalidAtcaIp = 0;
    blenStats.fcomInvalidAtcaIpPort = 0;
    blenStats.cannotCreateSocket = 0;
    blenStats.sendToFailed = 0;
}

// Get fcom ID related to BPM PV
void BlenFcom::registerTmitId(std::string pvName) {
    tmitId = fcomLCLSPV2FcomID(pvName.c_str());
}

// Get fcom ID related to this bunch length PV
void BlenFcom::registerArawId(std::string pvName) {
    aRawId = fcomLCLSPV2FcomID(pvName.c_str());
}

// Receives IP address and port in the format <IP>:<port>
void BlenFcom::registerAtcaIpToSendTMIT(std::string ipColonPort) {
    char* auxStr;
    // Sufficient space for a full IPv4 IP address 
    // plus a 5 digit port and a colon
    char ipColonPort_C[INET_ADDRSTRLEN + 6];
    // This string copy brings the C++ string format to C format
    strncpy(ipColonPort_C, ipColonPort.c_str(), sizeof(ipColonPort_C));

    // Extract the IP address information from the function parameter
    auxStr = strtok(ipColonPort_C, ":");


    // Clean sockaddr_in structure
    memset((char *)&atcaIpToSendTMIT, 0, sizeof(atcaIpToSendTMIT));
    // Test to see if we have a valid IPv4 
    // format address and registers the result
    if (inet_pton( AF_INET, auxStr, &(atcaIpToSendTMIT.sin_addr) ) <= 0) {
        errlogPrintf("IP address format invalid: %s\n", auxStr);
        blenStats.fcomInvalidAtcaIp = 1;
    }

    // Extract the port from the function parameter
    auxStr = strtok(NULL, ":");

    if (auxStr != NULL) {
        // Register port in IP addr structure in network byte order
        atcaIpToSendTMIT.sin_port = htons( atoi(auxStr) );
    } else {
        errlogPrintf("Port number invalid!\n");
        blenStats.fcomInvalidAtcaIpPort = 1;
    }

    // Try to create socket and register if success or not
    socketFd = socket(PF_INET, SOCK_DGRAM, 0);
    blenStats.cannotCreateSocket = (socketFd < 0);
}

int BlenFcom::fireFcomTask() {
    int rc = 0;
    int st = 0;
    
    /* subscribe to the TMIT value */
    rc = fcomSubscribe(tmitId, FCOM_SYNC_GET);
    if ( rc ) {
        errlogPrintf("ERROR: %s\n", fcomStrerror(st));
        return(-1);
    }

    epicsThreadCreate("blenFcomTask", epicsThreadPriorityHigh+3,
                  epicsThreadGetStackSize(epicsThreadStackMedium),
                  (EPICSTHREADFUNC) C_fcomTask, NULL);

    return 0;
}

void BlenFcom::processBlob(FcomBlobRef bpmBlob) {
    // If the IP or port are invalid, there is nothing we can do here
    if ( (0 != blenStats.fcomInvalidAtcaIp) || 
         (0 != blenStats.fcomInvalidAtcaIpPort) ) 
    {
        return;
    }

    // Try to create socket and register if success or not,
    // only if it failed before
    if (blenStats.cannotCreateSocket) {
        socketFd = socket(PF_INET, SOCK_DGRAM, 0);
        blenStats.cannotCreateSocket = (socketFd < 0);
    }
    // It is impossible to continue without having a socket
    if (blenStats.cannotCreateSocket) {
        blenStats.sendToFailed = 1;
        return;
    }

    // Prepare packet to be sent via UDP to the firmware
    struct tTmitPacket tmitPack;
    // Always put zero on header
    tmitPack.header = 0;

    tmitPack.timel = bpmBlob->hdr.tsLo;
    tmitPack.timeu = bpmBlob->hdr.tsHi;
    // TMIT is the same for both sensors, so both of them get the same status
    // that arrived from the BPM through FCOM.
    tmitPack.statusA = tmitPack.statusB = bpmBlob->fc_stat;
    // Convert TMIT from float to integer 32 (firmware works with integer. Same
    // TMIT for both sensors.
    tmitPack.tmitA = tmitPack.tmitB = static_cast<uint32_t>(bpmBlob->fcbl_bpm_T);

    char *tmitPack_bytes = new char[sizeof(struct tTmitPacket)];

    if (tmitPack_bytes) {
        // Convert struct into an array of char. This works only because the struct
        // does not contain pointers. 
        memcpy((void*)tmitPack_bytes, (void*)&tmitPack, sizeof(struct tTmitPacket));
    
        // Try to send packet to the ATCA card. If answer is negative,
        // register a failure.
        blenStats.sendToFailed = ( sendto(socketFd, tmitPack_bytes, 
                                      sizeof(struct tTmitPacket), 0, 
                                      (struct sockaddr *)&atcaIpToSendTMIT, 
                                      sizeof(atcaIpToSendTMIT)) < 0 );
    } else {
        blenStats.sendToFailed = 1;
    }
    
    delete[] tmitPack_bytes;

    // Register statistical data for blenReport
    blenStats.lastTmit = bpmBlob->fcbl_bpm_T;
    blenStats.lastX = bpmBlob->fcbl_bpm_X;
    blenStats.lastY = bpmBlob->fcbl_bpm_Y;
    blenStats.lastTimeStampHi = bpmBlob->hdr.tsHi;
    blenStats.lastTimeStampLo = bpmBlob->hdr.tsLo;
}

void BlenFcom::fcomTask() {
    FcomBlobRef bpmBlob;
    int st;

    while (1) {
        // Wait for BPM blob to arrive
        st = fcomGetBlob( tmitId, &bpmBlob, blmFcomTimeoutMs /* ms */ );
        if ( 0 == st ) {
            if ( bpmBlob->fc_stat ) {
                // Commented due to the number of messages on the IOC console
                //errlogPrintf("Blob status flag %d indicates a problem with the data.\n", bpmBlob->fc_stat);
                blenStats.fcomStatErrors++;
            } else {
                /* Everything OK */
                blenStats.fcomProcessed++;
            }

            // Extracts data from blob and send TMIT to ATCA, even if we have a
            // data with status different of zero (firmware will take care of
            // this).
            processBlob(bpmBlob);
            fcomReleaseBlob(&bpmBlob);
        } else {
            switch ( st ) {
                case FCOM_ERR_TIMEDOUT:
                    // Timeout when waiting for fcom blob arrival
                    blenStats.fcomTimeouts++;
                    break;

                default:
                    blenStats.fcomErrors++;
            } // switch
        } // else
    } // while (1)
}

// Sends data to subscribed systems, like Fast Feedback
void BlenFcom::sendData(bsaData_t* bsaData) {
    FcomGroup fcomGroup;
    int st;
    
    st = fcomAllocGroup(FCOM_ID_ANY, &fcomGroup);
    if (st) {
        blenStats.fcomTxError++;
        return;
    }

    // Fill array with blen data
    blenTxBlob.fc_flt = blenTxData;
    blenTxBlob.fcbl_blen_araw = static_cast<float>(bsaData->aSum);
    blenTxBlob.fcbl_blen_braw = static_cast<float>(bsaData->bSum);
    blenTxBlob.fcbl_blen_aimax = static_cast<float>(bsaData->aImax);
    blenTxBlob.fcbl_blen_bimax = static_cast<float>(bsaData->bImax);

    blenTxBlob.fc_tsHi = bsaData->timeStamp.secPastEpoch;
    blenTxBlob.fc_tsLo = bsaData->timeStamp.nsec;

    blenTxBlob.fc_vers = FCOM_PROTO_VERSION;
    blenTxBlob.fc_idnt = aRawId;
    blenTxBlob.fc_type = FCOM_EL_FLOAT;
    blenTxBlob.fc_nelm = 4;

    // If there is a problem with the data, status of the data is ored with the
    // masks provided by fcomLclsBlen.h
    blenTxBlob.fc_stat = FC_STAT_BLEN_OK;
    blenTxBlob.fc_stat |= (bsaData->aStat != epicsAlarmNone) ? 
                                    FC_STAT_BLEN_INVAL_AIMAX_MASK : 0;
    blenTxBlob.fc_stat |= (bsaData->bStat != epicsAlarmNone) ? 
                                    FC_STAT_BLEN_INVAL_BIMAX_MASK : 0;

    // Add blob to group
    st = fcomAddGroup(fcomGroup, &blenTxBlob);
    if (st) {
        blenStats.fcomTxError++;
        return;
    }

    // Send group to multicast network
    st = fcomPutGroup(fcomGroup);
    if (st) {
        blenStats.fcomTxError++;
        return;
    }

    // Statistical data for blenReport
    blenStats.fcomTransmitted++;
    blenStats.lastAimaxSent = blenTxBlob.fcbl_blen_aimax;
}

struct tBlenStats BlenFcom::getStats() {
    return blenStats;
}

BlenFcom::~BlenFcom() {
    if (socketFd > 0) {
        close(socketFd);
    }
    fcomUnsubscribe(tmitId);
    delete instance;
}
