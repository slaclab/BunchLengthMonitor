#ifndef CPSW_STREAM_BSA_H
#define CPSW_STREAM_BSA_H

#include <string>

class CpswStreamBSA {
private:
    std::string streamName;
    int counterPacketsToDump;
    // Singleton design pattern: here is the pointer for the only instance of
    // this class.
    static CpswStreamBSA* instance;
    // Private constructor for Singleton design pattern
    CpswStreamBSA();
    // Private copy constructor and copy assignment operator, to avoid someone
    // to clone the object (we want only one instance)
    CpswStreamBSA(const CpswStreamBSA&);
    CpswStreamBSA& operator=(const CpswStreamBSA&);
public:
    ~CpswStreamBSA();
    // Singleton method to retrieve pointer to the only object that can be
    // instantiated from this class.
    static CpswStreamBSA* getInstance();
    void setStreamName(std::string strmName);
    void setNumberPacketsToDump(int numberOfPackets);
    int fireStreamTask();
    void streamTask();
};

#endif // CPSW_STREAM_BSA_H
