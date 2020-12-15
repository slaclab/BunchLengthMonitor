#ifndef BLEN_BSA_H
#define BLEN_BSA_H

#include <array>

#include "BsaApi.h"

constexpr int NUM_CHANNELS = 4;

// Data to be sent to BSA channels
struct bsaData_t {
    epicsTimeStamp timeStamp;

    double         aImax;
    double         aSum;
    BsaStat        aStat;
    BsaSevr        aSevr;

    double         bImax;
    double         bSum;
    BsaStat        bStat;
    BsaSevr        bSevr;
};

class BlenBSA {
public:
    BlenBSA() = default;
    ~BlenBSA() = default;

    BlenBSA(const BlenBSA &) = delete;
    BlenBSA(BlenBSA &&) = delete;

    BlenBSA& operator=(const BlenBSA &) = delete;
    BlenBSA& operator=(BlenBSA &&) = delete;

    void createChannels(const char *stationName);
    void sendData(const bsaData_t& bsaData);

    inline static constexpr std::array<const char *, NUM_CHANNELS> channelNames = {
        "AIMAX", "BIMAX", "ARAW", "BRAW",
    };

private:
    std::array<BsaChannel, NUM_CHANNELS> bsaChannels;
};

#endif // BLEN_BSA_H
