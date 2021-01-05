#include <mutex>
#include <string>
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

static void streamTask([[gnu::unused]] void *p)
{
    CpswStreamBSA::getInstance()->streamTask();
}

void CpswStreamBSA::configureAndRun(const char *stationName, const char *streamName)
{
    streamName_ = streamName;
    blenBSA_.createChannels(stationName);

    epicsThreadCreate(streamName_.c_str(), epicsThreadPriorityHigh + 3,
                  epicsThreadGetStackSize(epicsThreadStackMedium),
                  (EPICSTHREADFUNC) ::streamTask, nullptr);
}

void CpswStreamBSA::setNumberPacketsToDump(int numberOfPackets)
{
    std::lock_guard<epicsMutex> l(mutex_);

    counterPacketsToDump_ = numberOfPackets;
}

// Dump contents of BSA stream, case the user run the command on
// the IOC shell. The user can choose how many sequence packets to be shown.
void CpswStreamBSA::dumpPackets(uint8_t *buf)
{
    int pkts_remaining;
    {
        std::lock_guard<epicsMutex> l(mutex_);
        pkts_remaining = counterPacketsToDump_ - 1;
    }

    printf("\nBSA stream dump - %d packets remaining", pkts_remaining);
    for (size_t i = 0; i < STREAM_LENGTH; ++i) {
        if (i % 4 == 0)
            printf("\n%lu   ", i / 4);

        // Fix for endianess
        auto buf_idx = static_cast<int>(4 * floor(i / 4.0) + 3 - i % 4);
        printf ("%02X ", buf[buf_idx]);
    }

    {
        std::lock_guard<epicsMutex> l(mutex_);
        --counterPacketsToDump_;
    }

    printf("\n");
}

void CpswStreamBSA::streamTask() {
    uint8_t buf[STREAM_LENGTH];

    stream_t* streamData;
    bsaData_t bsaData;

    payload_t AMC0;
    payload_t AMC1;
    
    BlenFcom* pBlenFcom = BlenFcom::getInstance();
    
    auto streamPath = cpswGetRoot()->findByName(streamName_.c_str());
    auto stream = IStream::create(streamPath);

    while (1) {
        uint32_t count = stream->read(buf, sizeof(buf), 50000);

        // Map buf's content with the stream structure
        streamData = (stream_t*) buf;
        AMC0 = streamData->AMC0_Data;
        AMC1 = streamData->AMC1_Data;

        bool shouldDumpPackets = false;
        {
            std::lock_guard<epicsMutex> l(mutex_);
            shouldDumpPackets = counterPacketsToDump_ > 0;
        }

        if (shouldDumpPackets)
            dumpPackets(buf);

        /*
         * Somehow, the word order for timestamp in data stream has been swapped.
         * We are going to swap the word order in software side until firmware fix it.
         */
        auto timeStamp = streamData->timingHeader.time;
        std::swap(timeStamp.secPastEpoch, timeStamp.nsec);
        bsaData.timeStamp = timeStamp;

        gatherData(bsaData, AMC0, AMC1);
        gatherAlarms(bsaData, AMC0, AMC1);

        if (streamData->AMC0_Data.status1 & BSA_MESSAGE)
            blenBSA_.sendData(bsaData);

        pBlenFcom->sendData(bsaData);
    }
}

void CpswStreamBSA::gatherData(bsaData_t& bsaData, payload_t& AMC0, payload_t& AMC1)
{
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
            bsaData.aImax = AMC0.iMax;
        } else {
            bsaData.aImax = 0;
        }

        if (  (AMC1.status1 & BEAMFULL)
               && ! (AMC1.status0 & (TMIT_BELLOW_THRES
                                   | TMIT_STATUS_NOT_0))
               && (AMC1.sum > SUM_THRES) ) {
            bsaData.bImax = AMC1.iMax;
        } else {
            bsaData.bImax = 0;
        }

        bsaData.aSum = AMC0.sum;
        bsaData.bSum = AMC1.sum;
}

void CpswStreamBSA::gatherAlarms(bsaData_t& bsaData, payload_t& AMC0, payload_t& AMC1)
{
    // By default, no alarms
    bsaData.aStat = epicsAlarmNone;
    bsaData.aSevr = epicsSevNone;
    bsaData.bStat = epicsAlarmNone;
    bsaData.bSevr = epicsSevNone;

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
            bsaData.aStat = epicsAlarmCalc;
            bsaData.aSevr = epicsSevInvalid;
        }
        if (AMC1.status0 & SENSB_CALC_ERROR) {
            bsaData.bStat = epicsAlarmCalc;
            bsaData.bSevr = epicsSevInvalid;
        }
        if (AMC0.status0 & SENSA_DIVIDE_BY_0) {
            bsaData.aStat = epicsAlarmUDF;
            bsaData.aSevr = epicsSevInvalid;
        }
        if (AMC1.status0 & SENSB_DIVIDE_BY_0) {
            bsaData.bStat = epicsAlarmUDF;
            bsaData.bSevr = epicsSevInvalid;
        }
    }

    // Record issues when delivering TMIT to the firmware
    if (AMC0.status0 & NO_TMIT_RECEIVED ) {
        bsaData.aStat = epicsAlarmRead;
        bsaData.aSevr = epicsSevInvalid;
    }
    if (AMC1.status0 & NO_TMIT_RECEIVED ) {
        bsaData.bStat = epicsAlarmRead;
        bsaData.bSevr = epicsSevInvalid;
    }
}

