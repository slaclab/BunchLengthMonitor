#include <iostream>
#include <string>
#include <vector>
#include <cmath>

#include <epicsThread.h>
#include <alarm.h>
#include <epicsTime.h>

#include "cpswStreamBSA.h"
#include "streamDataType.h"
#include "blenBSA.h"
#include "blenFcom.h"

#include <cpsw_api_user.h>
#include "yamlLoader.h"

static void C_streamTask([[gnu::unused]] void *p)
{
    CpswStreamBSA::getInstance()->streamTask();
}

// Singleton design pattern: initialize class instance pointer to null.
CpswStreamBSA* CpswStreamBSA::instance = 0;

// Get the instance pointer for the class. If it is the first time,
// create a new one.
CpswStreamBSA* CpswStreamBSA::getInstance() {
    if (instance == 0) {
        instance = new CpswStreamBSA();
    }

    return instance;
}

CpswStreamBSA::CpswStreamBSA() {
    counterPacketsToDump = 0;
}

// This is the name of the stream responsible to send BSA data from the ATCA
// to the network. The name is defined in the yaml file, and is sent to the
// object as a parameter in st.cmd.
void CpswStreamBSA::setStreamName(std::string strmName) {  
    streamName = strmName; 
}

int CpswStreamBSA::fireStreamTask() {
    epicsThreadCreate(streamName.c_str(), epicsThreadPriorityHigh + 3,
                  epicsThreadGetStackSize(epicsThreadStackMedium),
                  (EPICSTHREADFUNC) C_streamTask, NULL);

    return 0;
}

void CpswStreamBSA::streamTask() {
    uint8_t buf[STREAM_LENGTH];
    uint32_t count = 0;

    stream_t* streamData;
    payload_t AMC0;
    payload_t AMC1;
    epicsTimeStamp timeStamp;

    // Counters for loop
    std::size_t aaa; // To get rid of compiler warning messages
    int buf_idx;
    
    bsaData_t* bsaData = (bsaData_t*) malloc(sizeof(bsaData_t));
    epicsTimeStamp* timeStampAux = (epicsTimeStamp*) malloc(sizeof(epicsTimeStamp));

    // Get instance of the object that sends the data to the BSA core
    BlenBSA* pBlenBSA = BlenBSA::getInstance();

    // Get instance of the object that sends data to the FCOM network
    BlenFcom* pBlenFcom = BlenFcom::getInstance();
    
    // Get stream according to the stream name informed in the IOC shell
    Path p = cpswGetRoot();
    Path strm_name = p->findByName(streamName.c_str());
    Stream stream = IStream::create(strm_name);

    while (1) {
        // Receive stream from the firmware and write it in buf
        count = stream->read(buf, sizeof(buf), 50000);
        //epicsTime before = epicsTime::getCurrent();

        if (count != STREAM_LENGTH) {
            // Do something?
        } else {
            // Map buf's content with the stream structure
            streamData = (stream_t*) buf;
            AMC0 = streamData->AMC0_Data;
            AMC1 = streamData->AMC1_Data;
            timeStamp = streamData->timingHeader.time;

            // Dump contents of BSA stream, case the user run the command on
            // the IOC shell. The user can choose how many sequence packets he
            // wants to be shown.
            if (counterPacketsToDump) {
                printf("\nBSA stream dump - %d packets remaining", counterPacketsToDump-1);
                for (aaa=0; aaa<STREAM_LENGTH;++aaa) {
                    if (!(aaa % 4)) {
                        printf("\n%lu   ", aaa/4);
                    }
                    // Fix for endianess
                    buf_idx = static_cast<int>(4*floor(aaa/4.0)+3-aaa%4);
                    printf ("%02X ", buf[buf_idx]);
                }
                --counterPacketsToDump;
                printf("\n");
            }

            /*
             * Somehow, the word order for timestamp in data stream has been swapped.
             * We are going to swap the word order in software side until firmware fix it.
             */
            timeStampAux->nsec = timeStamp.secPastEpoch;
            timeStampAux->secPastEpoch  = timeStamp.nsec;
            bsaData->timeStamp = *timeStampAux;

            /* Store in bsaData structure to send later to object that will store
             * it in the BSA channels. 
             * Conditions that forces i max to zero amperes, as convention:
             * - TMIT arriving from BPB with invalid flag
             * - TMIT below a threshold
             * - Sum of the raw waveform below a threshold
             * - Beam full flag from timing pattern equal to zero
             */ 
            if (  (AMC0.status1 & BEAMFULL) 
                   && ! (AMC0.status0 & (TMIT_BELLOW_THRES 
                                       | TMIT_STATUS_NOT_0)) 
                   && (AMC0.sum > SUM_THRES) ) {
                bsaData->aImax = AMC0.iMax;
            } else {
                bsaData->aImax = 0;
            }

            if (  (AMC1.status1 & BEAMFULL) 
                   && ! (AMC1.status0 & (TMIT_BELLOW_THRES 
                                       | TMIT_STATUS_NOT_0)) 
                   && (AMC1.sum > SUM_THRES) ) {
                bsaData->bImax = AMC1.iMax;
            } else {
                bsaData->bImax = 0;
            }
            
            bsaData->aSum = AMC0.sum;
            bsaData->bSum = AMC1.sum;

            // Now, the alarm status flags.
            // By default, no alarms
            bsaData->aStat = epicsAlarmNone; 
            bsaData->aSevr = epicsSevNone;
            bsaData->bStat = epicsAlarmNone;
            bsaData->bSevr = epicsSevNone;

            /* We trigger EPICS alarms only if TMIT is above the threshold.
             * Below threshold we have no beam and, so, we don't bother BSA
             * with alarm status. 
             *
             * There is only one source of TMIT and the threshold is always the
             * same for both daughter cards. So the TMIT_BELLOW_THRES flag will
             * have the same status for both AMC0 and AMC1. We are placing both
             * in an OR here just in case someday 2 different TMITs are used.
             */
            if (!(AMC0.status0 & TMIT_BELLOW_THRES) ||
               !(AMC1.status0 & TMIT_BELLOW_THRES) ) { 
                // Apply masks to the status words. If some of the bits are 1,
                // a bad condition exists.
                if (AMC0.status0 & SENSA_CALC_ERROR) {
                    bsaData->aStat = epicsAlarmCalc;
                    bsaData->aSevr = epicsSevInvalid;
                }
                if (AMC1.status0 & SENSB_CALC_ERROR) {
                    bsaData->bStat = epicsAlarmCalc;
                    bsaData->bSevr = epicsSevInvalid;
                }
                if (AMC0.status0 & SENSA_DIVIDE_BY_0) {
                    bsaData->aStat = epicsAlarmUDF;
                    bsaData->aSevr = epicsSevInvalid;
                }
                if (AMC1.status0 & SENSB_DIVIDE_BY_0) {
                    bsaData->bStat = epicsAlarmUDF;
                    bsaData->bSevr = epicsSevInvalid;
                }
            }
            
            // Issues when delivering TMIT to the firmware
            if (AMC0.status0 & NO_TMIT_RECEIVED ) { 
                bsaData->aStat = epicsAlarmRead;
                bsaData->aSevr = epicsSevInvalid;
            }
            if (AMC1.status0 & NO_TMIT_RECEIVED ) { 
                bsaData->bStat = epicsAlarmRead;
                bsaData->bSevr = epicsSevInvalid;
            }

            // Send data to the BSA core, case the stream sent from the
            // firmware is related to BSA data. LSB from status1 indicates
            // if the message is BSA data or not.
            if (streamData->AMC0_Data.status1 & BSA_MESSAGE)
                pBlenBSA->sendData(bsaData);

            // Send data to the FCOM network
            pBlenFcom->sendData(bsaData);

            //epicsTime after = epicsTime::getCurrent();
            //epicsTime diff = after - before;
            //printf("Time spent = %f\n", after - before);
        }

    } // while (1) 
}

void CpswStreamBSA::setNumberPacketsToDump(int numberOfPackets) {
    counterPacketsToDump = numberOfPackets;
}

CpswStreamBSA::~CpswStreamBSA() {
    delete instance;
}
