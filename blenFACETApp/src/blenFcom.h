#ifndef BLEN_FCOM_H
#define BLEN_FCOM_H

#include <string>
#include <netinet/ip.h>

#include <epicsTime.h>

#include <fcomUtil.h>

#include <blenBSA.h>

// Number of BLEN parameters that must be sent through FCOM
#define NUM_BLEN_PARAM 4

// Statistics related to FCOM in bunch length
struct tBlenStats {
    // Last TMIT, X, and Y values read from the BPM through FCOM
    float lastTmit;
    float lastX;
    float lastY;
    // Timestamp associated with last FCOM message processed
    uint32_t lastTimeStampHi;
    uint32_t lastTimeStampLo;
    float lastAimaxSent;
    float lastBimaxSent;
    // Number of times a timeout happened when waiting for FCOM data from BPM
    int fcomTimeouts;
    // Number of times a message error was reported when reading FCOM
    int fcomErrors;
    // Number of times an FCOM message arrived with an error status
    int fcomStatErrors;
    // Number of times an FCOM message was received and processed succesfuly
    int fcomProcessed;
    // Number of times an FCOM message was transmitted succesfuly
    int fcomTransmitted;
    // Number of times an error happened when sending FCOM message
    int fcomTxError;
    // Invalid IP and port to send TMIT to the ATCA
    int fcomInvalidAtcaIp;
    int fcomInvalidAtcaIpPort;
    // Problems when sending TMIT to the ATCA
    int cannotCreateSocket;
    int sendToFailed; 

    epicsTime diff;
};

// Packet format to send TMIT to the ATCA firmware
struct tTmitPacket {
    uint32_t header;
    uint32_t timel;
    uint32_t timeu;
    uint32_t statusA;
    uint32_t statusB;
    uint32_t tmitA;
    uint32_t tmitB;
    // The last 4 words are related to X and Y positions from BPM
    uint32_t unused[4];
};

class BlenFcom {
private:
    FcomID tmitId;
    FcomID aRawId;
    struct tBlenStats blenStats;
    struct sockaddr_in atcaIpToSendTMIT;
    int socketFd;
    // Blob to be sent to FCOM
    FcomBlob blenTxBlob;
    // Data inside blob that is sent to FCOM
    float blenTxData[NUM_BLEN_PARAM];
    // Singleton design pattern: here is the pointer for the only instance of
    // this class.
    static BlenFcom* instance;
    // Private constructor for Singleton design pattern
    BlenFcom();
    // Private copy constructor and copy assignment operator, to avoid someone
    // to clone the object (we want only one instance)
    BlenFcom(const BlenFcom&);
    BlenFcom& operator=(const BlenFcom&);
    void processBlob(FcomBlobRef tmitBlob);
public:
    ~BlenFcom();
    // Singleton method to retrieve pointer to the only object that can be
    // instantiated from this class.
    static BlenFcom* getInstance();
    void registerTmitId(std::string pvName);
    void registerArawId(std::string pvName);
    void registerAtcaIpToSendTMIT(std::string ipColonPort);
    int fireFcomTask();
    void fcomTask();
    void sendData(bsaData_t* bsaData);
    struct tBlenStats getStats();
};

#endif // BLEN_FCOM_H
