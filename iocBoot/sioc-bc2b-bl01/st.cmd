#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "BC2B")
epicsEnvSet("POS", "950")
epicsEnvSet("INST", "BZ21B")
epicsEnvSet("IOC_UNIT", "BL01")
epicsEnvSet("ATCA_SLOT", "4")
epicsEnvSet("BLEN_ASYN_PORT", "ATCA7")
epicsEnvSet("L2MPSASYN_PORT","L2MPSASYN_PORT")
epicsEnvSet("L2MPS_PREFIX", "MPLN:L2B:MP04:4")
epicsEnvSet("APPID", "71")
# Setting the Bunch Length threshold that defines which sensor to use:
epicsEnvSet("LEN", "11400")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsPyro.yaml")

epicsEnvSet("FPGA_IP", "10.1.1.104")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

# Motion control records
dbLoadRecords("db/motionCtrl.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/motionCtrlRB.db", "P=BLEN:$(AREA):$(POS)")

# Initialization Records
dbLoadRecords("db/initMode.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/initMode.db", "P=BLEN:$(AREA):$(POS), AMC=1")
dbLoadRecords("db/initMotion.db", "P=BLEN:$(AREA):$(POS)")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=BLEN:$(AREA):$(POS), SRC=ServerRemoteIp")

# BPM Scale Factors:
dbLoadRecords("db/blen_bpm_coef.db", "P=BLEN:$(AREA):$(POS), BPM0=BPMS:EMIT2:150, BPM1=BPMS:BC2B:530, AMC=0")
dbLoadRecords("db/blen_bpm_coef.db", "P=BLEN:$(AREA):$(POS), BPM0=BPMS:EMIT2:150, BPM1=BPMS:BC2B:530, AMC=1")

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
