# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================


# For crossbarControl DB prefix
epicsEnvSet("PART_PV", "$(AREA):$(IOC_UNIT)")


# *********************************************
# **** Environment variables for YCPSWASYN ****

# Use Automatic generation of records from the YAML definition.
# Usually it is 0.
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix, case the previous option is 1
epicsEnvSet("PREFIX","BLEN:$(AREA):$(POS)")

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/blen.dbd",0,0)
blen_registerRecordDeviceDriver(pdbbase)

# ===========================================
#              DRIVER SETUP
# ===========================================

## Yaml Downloader
DownloadYamlFile("$(FPGA_IP)", "$(YAML_DIR)")

# Load yaml files for CPSW
cpswLoadYamlFile("$(TOP_YAML)", "NetIODev", "", "$(FPGA_IP)")
cpswLoadConfigFile("$(YAML_CONFIG_FILE)", "mmio", "")

# Setup BSA Driver
# add BSA PVs
addBsa("AMC0:SENSPSUM",     "uint32")
addBsa("AMC0:BLEN",         "uint32")
addBsa("AMC0:TMITSTAT",     "uint32")
addBsa("AMC0:SENSPSUMFLOAT","float32")
addBsa("AMC0:BLENFLOAT",    "float32")
addBsa("AMC0:BLSTATUS",     "uint32")

addBsa("AMC1:SENSPSUM",     "uint32")
addBsa("AMC1:BLEN",         "uint32")
addBsa("AMC1:TMITSTAT",     "uint32")
addBsa("AMC1:SENSPSUMFLOAT","float32")
addBsa("AMC1:BLENFLOAT",    "float32")
addBsa("AMC1:BLSTATUS",     "uint32")

# BSA driver for yaml
bsaAsynDriverConfigure("bsaPort", "mmio/AmcCarrierCore/AmcCarrierBsa","strm/AmcCarrierDRAM/dram")

# Driver setup for YCPSWAsyn
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("$(BLEN_ASYN_PORT)", "", "$(PREFIX)", "$(AUTO_GEN)", "$(DICT_FILE)")

# Load drivers for TPR trigger
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")


# ===========================================
#               DB LOADING
# ===========================================

# metadata about the IOC
dbLoadRecords("db/iocMeta.db", "AREA=$(AREA),IOC_UNIT=$(IOC_UNIT)")

# main blen database - user facing PVs
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0")
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1")

# Additional offset coefficients for AMC0, AMC1 ch1 raw data
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1")

dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0, SENS=0")
dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1, SENS=0")

# FPGA-related records
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0")
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1")
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0, SENS=0")
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1, SENS=0")
dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT)")
dbLoadRecords("db/monitorFPGAReboot.db", "P=BLEN:$(AREA):$(POS)")

dbLoadRecords("db/streamControl.db", "AREA=$(AREA),POS=$(POS),AMC=0")
dbLoadRecords("db/streamControl.db", "AREA=$(AREA),POS=$(POS),AMC=1")

# Records to manipulate waveforms from detectors
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), SENS=0, AMC=0")
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), SENS=0, AMC=1")
##########################Only revelant to MR
##########################dbLoadRecords("db/processRawWFHeader.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)A")
##########################dbLoadRecords("db/processRawWFHeader.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)B")
dbLoadRecords("db/weightFunctionAmc.db", "AREA=$(AREA), POS=$(POS), AMC=0")
dbLoadRecords("db/weightFunctionAmc.db", "AREA=$(AREA), POS=$(POS), AMC=1")
dbLoadRecords("db/weightFunctionSensor.db", "AREA=$(AREA), POS=$(POS), INST=0, AMC=0")
dbLoadRecords("db/weightFunctionSensor.db", "AREA=$(AREA), POS=$(POS), INST=0, AMC=1")


dbLoadRecords("db/lcls2FPGA.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}") 
dbLoadRecords("db/bpmSelect.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/selectStatus.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/sensCalibration.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/sensCalibration.db", "P=BLEN:$(AREA):$(POS), AMC=1")
dbLoadRecords("db/coefficientScaling.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/coefficientScaling.db", "P=BLEN:$(AREA):$(POS), AMC=1")

dbLoadRecords("db/msgStatus.db", "P=BLEN:$(AREA):$(POS)")

# tpr high level PVs
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=00,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=01,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=02,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=03,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=04,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=05,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=06,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=07,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=08,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=09,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=10,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=11,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=12,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=13,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=14,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=15,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG15:,PORT=trig")


# **** Load BSA driver DB ****

dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:SENSPSUM,SECN=SENSPSUM")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:BLEN,SECN=BLEN")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:SENSPSUMFLOAT,SECN=SENSPSUMFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsaPort,BSAKEY=AMC0:BLSTATUS,SECN=BLSTATUS")

dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:SENSPSUM,SECN=SENSPSUM")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:BLEN,SECN=BLEN")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:SENSPSUMFLOAT,SECN=SENSPSUMFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsaPort,BSAKEY=AMC1:BLSTATUS,SECN=BLSTATUS")

# Timing trigger
# INST = Instance Number (for multiple instances of tprTrigger in an IOC)
# The convention adopted is to set INST to the ATCA slot
dbLoadRecords("db/tprTrig.db",     "LOCA=$(AREA), IOC_UNIT=$(IOC_UNIT), INST=${ATCA_SLOT}, PORT=trig")

# **********************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ****
dbLoadRecords("db/iocAdminSoft.db","IOC=$(IOC_NAME)")
dbLoadRecords("db/iocAdminScanMon.db","IOC=$(IOC_NAME)")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=$(IOC_NAME)")

# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< $(ACF_INIT)

# ===========================================
#           ARCHIVER FILES
# ===========================================
system("cp $(TOP)/archive/$(IOC).archive $(IOC_DATA)/$(IOC)/archive")

# ===========================================
#   LOAD FACET, LCLS1 (MR) or LCLS2 CONFIG 
# ===========================================
#< iocBoot/common/blen$(BLEN_VERSION).cmd

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================
< iocBoot/common/init_restore_soft.cmd

#////////////////////////////////////////#
#Run script to generate archiver files   #
#////////////////////////////////////////#
cd(${TOP}/blenApp/scripts/)
system("./makeArchive.sh ${IOC} &")
cd(${TOP})

