#ifndef STREAM_DATATYPE_H
#define STREAM_DATATYPE_H

#include <epicsTypes.h>
#include <epicsTime.h>
#include <sys/time.h>

/* Mask for status word:
 * - Sensor A calculation errors
 * - Sensor B calculation errors
 * - Sensor A calculation has division by zero
 * - Sensor B calculation has division by zero 
 * - TMIT value bellow programmed threshold  
 * - No TMIT was received
 * - Delivered TMIT status is not zero  */
#define SENSA_CALC_ERROR 0x17
#define SENSB_CALC_ERROR 0x05C0
#define SENSA_DIVIDE_BY_0 0x28
#define SENSB_DIVIDE_BY_0 0x0A00
#define TMIT_BELLOW_THRES 0x1000
#define NO_TMIT_RECEIVED 0x2000
#define TMIT_STATUS_NOT_0 0x4000

// For status1
#define BSA_MESSAGE 0x01 // Message is to be stored in BSA
#define BEAMFULL 0x02 // dmod(83) bit meaning beam present

// Threshold for the waveform sum
#define SUM_THRES 0.000001

#define STREAM_LENGTH (sizeof(stream_t))

#pragma pack(push)
#pragma pack(1)

typedef struct {
    epicsTimeStamp  time;
    epicsUInt32     mod[6];
    epicsUInt32     edefAvgDoneMask;
    epicsUInt32     edefMinorMask;
    epicsUInt32     edefMajorMask;
    epicsUInt32     edefInitMask;
} timing_header_t;

typedef struct {
    epicsFloat32    sum;
    epicsFloat32    iMax;
    epicsFloat32    scaledTMIT;
    epicsUInt32     status0;
    epicsUInt32     status1;
    // Seven 32-bit words reserved for future use
    epicsUInt32     reservedWords[6];    
} payload_t;

/* This structure represents the entire content of the BSA stream message that
 * comes from the firmware. If the message content is changed, this structure
 * must be updated */
typedef struct {
    // Stream header is not described at the specification.
    epicsUInt64     streamHeader;
    epicsUInt32     headerWord;
    timing_header_t timingHeader;
    payload_t       AMC0_Data;
    payload_t       AMC1_Data;
} stream_t;

#pragma pack(pop)

#endif /* STREAM_DATATYPE_H */

