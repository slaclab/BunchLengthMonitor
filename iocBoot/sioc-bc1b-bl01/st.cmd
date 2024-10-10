#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "BC1B")
epicsEnvSet("POS", "850")
epicsEnvSet("INST", "BZ11B")
epicsEnvSet("IOC_UNIT", "BL01")
epicsEnvSet("ATCA_SLOT", "5")
epicsEnvSet("BLEN_ASYN_PORT", "ATCA7")
epicsEnvSet("L2MPSASYN_PORT","mpsPort")
epicsEnvSet("L2MPS_PREFIX", "MPLN:BC1B:MP02:5")
epicsEnvSet("APPID", "44")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsPyro.yaml")

epicsEnvSet("FPGA_IP", "10.1.1.105")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

# ======================================
# Setting up BLD for SIOC:BC1B:BL01
# ======================================

# Configuring BLD:
bldAssociateBsaChannels("bsaPort") 

# bldAsynDriverConfigure ("<BLD  port name>", "<yaml path to BLD>", "<prefix for the PAYLOAD PV>")
# The register path may be different from the example below. It depends
# on the application. The example, though, will probably fit most applications.
bldAsynDriverConfigure("bldPort", "mmio/AmcCarrierCore/AmcCarrierBsa/Bld", "TPR:$(AREA):$(IOC_UNIT):0")

# Give names for the signals that will participate on BLD.
# These names are shown in the content of the PAYLOAD PV when someone uses
# pvinfo ${TPR_PREFIX}:BLD_PAYLOAD
#bldChannelName("AMC0:SMOOTHED",    "TMIT 123")
#bldChannelName("AMC0:BLEN", "X 123")
#bldChannelName("AMC0:TMITSTAT", "Y 123")
#bldChannelName("AMC0:SMOOTHEDFLOAT",    "TMIT 123")
#bldChannelName("AMC0:BLENFLOAT", "X 123")
#bldChannelName("AMC0:BLSTATUS", "Y 123")
#bldChannelName("AMC0:RAW", "X 123")
#bldChannelName("AMC0:RAWFLAOT", "Y 123")
  
#bldChannelName("TMITAMC1",    "TMIT 345")
#bldChannelName("XFIXEDPAMC1", "X 345")
#bldChannelName("YFIXEDPAMC1", "Y 345")

# BLD rate control template
# DEV is the DEVICE:AREA:LOCAL of an IOC.
# There's a hidden ${GLOBAL} macro that defaults to TPG:SYS0:1. This matches the
# dev TPG in B34 and also in production. If you are using a different TPG, you
# need to redefine ${GLOBAL} with the correct prefix of the TPG.
# Example: dbLoadRecords("db/bldCtrl.db", "DEV=${TPR_PREFIX},PORT=bldPort,GLOBAL=TPG:B15:1")
# Below we are using the default TPG, so we don't need to provide GLOBAL.
dbLoadRecords("db/bldCtrl.db", "DEV=TPR:$(AREA):$(IOC_UNIT):0, PORT=bldPort")

# This database provides access to severity masks and allows enabling/disabling
# each signal individually.
# DEV is the DEVICE:AREA:LOCAL of an IOC.
# SECN is used as part of the PV name. The combination of DEV and SECN macros must
# be unique in the IOC. If you produce an identical pair of DEV and SECN more than
# once, you will have duplicate PVs in the IOC.
# BSAKEY must correspond with what was used with bsaAdd().
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLEN,SECN=BLEN")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0RAW,SECN=RAW")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0RAWFLOAT,SECN=RAWFLOAT")

dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLEN,SECN=BLEN")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1RAW,SECN=RAW")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1RAWFLOAT,SECN=RAWFLOAT")

# Motion control records
dbLoadRecords("db/motionCtrl.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/motionCtrlRB.db", "P=BLEN:$(AREA):$(POS)")

# Initialization records
dbLoadRecords("db/initMode.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/initMode.db", "P=BLEN:$(AREA):$(POS), AMC=1")
dbLoadRecords("db/initMotion.db", "P=BLEN:$(AREA):$(POS)")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=BLEN:$(AREA):$(POS), SRC=ServerRemoteIp")

# BPM Scale Factors:
dbLoadRecords("db/blen_bpm_coef.db", "P=BLEN:$(AREA):$(POS), BPM0=BPMS:COL1:120, BPM1=BPMS:BC1B:440, AMC=0")
dbLoadRecords("db/blen_bpm_coef.db", "P=BLEN:$(AREA):$(POS), BPM0=BPMS:COL1:120, BPM1=BPMS:BC1B:440, AMC=1")

# ===========================================
#               IOC INIT
# ===========================================
callbackSetQueueSize(12000)
iocInit()

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("$(EPICS_CA_PUT_LOG_ADDR)")
caPutLogShow(2)

< iocBoot/common/start_restore_soft.cmd

epicsThreadSleep(20)
# Switching to running mode to allow autosave to put values in A0 and A1 coefficients
dbpf BLEN:${AREA}:${POS}:0:CALIBMODEINIT.PROC 1
dbpf BLEN:${AREA}:${POS}:1:CALIBMODEINIT.PROC 1
# Forcing the motors to process to fix mismatched readback and control values
dbpf BLEN:${AREA}:${POS}:MOTIONINIT.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT2.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT3.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT4.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT5.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT6.PROC 1
epicsThreadSleep(2)
dbpf BLEN:${AREA}:${POS}:MOTIONINIT7.PROC 1

# Enabling MPS
dbpf ${L2MPS_PREFIX}:THR_LOADED 1
dbpf ${L2MPS_PREFIX}:MPS_EN 1
