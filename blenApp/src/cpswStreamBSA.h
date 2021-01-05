#ifndef CPSW_STREAM_BSA_H
#define CPSW_STREAM_BSA_H

#include <string>

#include <epicsMutex.h>

#include "blenBSA.h"
#include "streamDataType.h"

class CpswStreamBSA
{
public:
    ~CpswStreamBSA() { delete instance; }

    CpswStreamBSA(const CpswStreamBSA &) = delete;
    CpswStreamBSA(CpswStreamBSA &&) = delete;

    CpswStreamBSA& operator=(const CpswStreamBSA &) = delete;
    CpswStreamBSA& operator=(CpswStreamBSA &&) = delete;

    void configureAndRun(const char *stationName, const char *streamName);
    void setNumberPacketsToDump(int numberOfPackets);
    void streamTask();

    static CpswStreamBSA* getInstance()
    {
        if (!instance)
            instance = new CpswStreamBSA();
        return instance;
    }

private:
    void dumpPackets(uint8_t *buf);
    void gatherData(bsaData_t& bsaData, payload_t& AMC0, payload_t& AMC1);
    void gatherAlarms(bsaData_t& bsaData, payload_t& AMC0, payload_t& AMC1);

    std::string     streamName_;
    int             counterPacketsToDump_ = 0;
    BlenBSA         blenBSA_;

    epicsMutex      mutex_;

    // Singleton
    CpswStreamBSA() = default;
    inline static CpswStreamBSA* instance = nullptr;
};

#endif // CPSW_STREAM_BSA_H
