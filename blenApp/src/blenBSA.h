#ifndef BLEN_BSA_H
#define BLEN_BSA_H

#include "BsaApi.h"

#define NUM_CHANNELS 4
static const char* const channelNames[NUM_CHANNELS] = {"AIMAX", "BIMAX", "ARAW", "BRAW"};

// Data to be sent to BSA channels
typedef struct bsaData_t {
    epicsTimeStamp timeStamp;

    double         aImax;
    double         aSum;
    BsaStat        aStat;
    BsaSevr        aSevr;

    double         bImax;
    double         bSum;
    BsaStat        bStat;
    BsaSevr        bSevr;
} bsaData_t;

class BlenBSA {
private:
    BsaChannel *bsaChannels;
    // Singleton design pattern: here is the pointer for the only instance of
    // this class.
    static BlenBSA* instance;
    // Private constructor for Singleton design pattern
    BlenBSA();
    // Private copy constructor and copy assignment operator, to avoid someone
    // to clone the object (we want only one instance)
    BlenBSA(const BlenBSA&);
    BlenBSA& operator=(const BlenBSA&);
public:
    ~BlenBSA();
    // Singleton method to retrieve pointer to the only object that can be
    // instantiated from this class.
    static BlenBSA* getInstance();
    int createChannels(const char *stationName);
    void sendData(bsaData_t* bsaData);
};

#endif // BLEN_BSA_H
