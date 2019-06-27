#include <iostream>

#include "blenBSA.h"

// Singleton design pattern: initialize class instance pointer to null.
BlenBSA* BlenBSA::instance = 0;

// Get the instance pointer for the class. If it is the first time,
// create a new one.
BlenBSA* BlenBSA::getInstance() {
    if (instance == 0) {
        instance = new BlenBSA();
    }

    return instance;
}

BlenBSA::BlenBSA() {

}

int BlenBSA::createChannels(const char *stationName) {
    char param_name[64];

    bsaChannels = new BsaChannel[NUM_CHANNELS];

    /* Create NUM_CHANNELS BSA channels with the name formed by the 
     * stationName that comes from the IOC shell, plus the channel
     * acronym defined by the constant array channelNames. */
    using namespace std;
    for (int i = 0; i < NUM_CHANNELS; i++) {
        sprintf(param_name, "%s:%s", stationName, channelNames[i]);
        bsaChannels[i] = BSA_CreateChannel(param_name);
        cout << __func__ << " created BSA channel " << param_name << ", (" << 
                bsaChannels[i] << ")" << endl;
    }

    return 0; 
}

void BlenBSA::sendData(bsaData_t* bsaData) {
    BSA_StoreData(bsaChannels[0], bsaData->timeStamp, bsaData->aImax,
                  bsaData->aStat, bsaData->aSevr);
    BSA_StoreData(bsaChannels[1], bsaData->timeStamp, bsaData->bImax,
                  bsaData->bStat, bsaData->bSevr); 
    BSA_StoreData(bsaChannels[2], bsaData->timeStamp, bsaData->aSum,
                  bsaData->aStat, bsaData->aSevr);
    BSA_StoreData(bsaChannels[3], bsaData->timeStamp, bsaData->bSum,
                  bsaData->bStat, bsaData->bSevr);
//std::cout << "bsaData->bSum = " << bsaData->bSum << std::endl;
}

BlenBSA::~BlenBSA() {
    delete instance;
}

