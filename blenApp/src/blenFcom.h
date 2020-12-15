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
struct BlenStats {
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

class BlenFcom final {
public:
    // Singleton so we don't want copy or move operations
    BlenFcom(const BlenFcom&) = delete;
    BlenFcom(BlenFcom&&) = delete;

    BlenFcom& operator=(const BlenFcom&) = delete;
    BlenFcom& operator=(BlenFcom&&) = delete;

    ~BlenFcom();

    static BlenFcom* getInstance();
    const auto& getStats() const { return blenStats; }

    void registerTmitId(std::string);
    void registerArawId(std::string);
    void registerAtcaIpToSendTMIT(std::string);

    int fireFcomTask();
    void fcomTask();
    void sendData(const bsaData_t& bsaData);
    void setTimeout(int timeout) { blmFcomTimeoutMs_ = timeout; }

private:
    // Private constructor for Singleton design pattern
    BlenFcom();

    void processBlob(FcomBlobRef);

    FcomID tmitId;
    FcomID aRawId;
    BlenStats blenStats;

    struct sockaddr_in atcaIpToSendTMIT;
    int socketFd;
    int blmFcomTimeoutMs_;

    FcomBlob blenTxBlob;
    float blenTxData[NUM_BLEN_PARAM];

    static BlenFcom* instance;

};

#endif // BLEN_FCOM_H
