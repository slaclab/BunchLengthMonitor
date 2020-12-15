#include <cstdio>
#include <iostream>

#include "blenBSA.h"


void BlenBSA::createChannels(const char *stationName) {
    char param_name[64];

    /* Create NUM_CHANNELS BSA channels with the name formed by the 
     * stationName that comes from the IOC shell, plus the channel
     * acronym defined by the constant array channelNames. */
    for (int i = 0; i < NUM_CHANNELS; i++) {
        sprintf(param_name, "%s:%s", stationName, channelNames[i]);
        bsaChannels[i] = BSA_CreateChannel(param_name);

        std::cout << __func__ << " created BSA channel " << param_name << ", ("
                  << bsaChannels[i] << ")\n";
    }
}

void BlenBSA::sendData(const bsaData_t& bsaData) {
    BSA_StoreData(bsaChannels[0], bsaData.timeStamp, bsaData.aImax,
                  bsaData.aStat, bsaData.aSevr);
    BSA_StoreData(bsaChannels[1], bsaData.timeStamp, bsaData.bImax,
                  bsaData.bStat, bsaData.bSevr);
    BSA_StoreData(bsaChannels[2], bsaData.timeStamp, bsaData.aSum,
                  bsaData.aStat, bsaData.aSevr);
    BSA_StoreData(bsaChannels[3], bsaData.timeStamp, bsaData.bSum,
                  bsaData.bStat, bsaData.bSevr);
}
