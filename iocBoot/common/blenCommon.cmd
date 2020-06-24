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
epicsEnvSet("PREFIX","BLEN:$(AREA):$(POS):$(INST)_")

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

# Load yaml files do CPSW
cpswLoadYamlFile("$(TOP_YAML)", "NetIODev", "", "$(FPGA_IP)")
cpswLoadConfigFile("$(YAML_CONFIG_FILE)", "mmio", "")

# Driver setup for YCPSWAsyn
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("cpsw", "", "$(PREFIX)", "$(AUTO_GEN)", "$(DICT_FILE)")

# Load drivers for TPR trigger
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")


# ===========================================
#               DB LOADING
# ===========================================

# main blen database - user facing PVs
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS):$(INST)A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS):$(INST)B, PORT=cpsw, AMC=1")

# FPGA-related records
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS):$(INST)A, PORT=cpsw, AMC=0")
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS):$(INST)B, PORT=cpsw, AMC=1")
dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:$(AREA):$(POS), PORT=cpsw")
dbLoadRecords("db/monitorFPGAReboot.db", "P=BLEN:$(AREA):$(POS), PORT=cpsw, KEY=0xFC067333")

dbLoadRecords("db/streamControl.db", "AREA=$(AREA),POS=$(POS),INSTA=$(INST)A,INSTB=$(INST)B")

# Records to manipulate waveforms from detectors
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)A")
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)B")
dbLoadRecords("db/processRawWFHeader.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)A")
dbLoadRecords("db/processRawWFHeader.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)B")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)A, AMC=0")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)B, AMC=1")


# Timing trigger
# INST = Instance Number (for multiple instances of tprTrigger in an IOC)
dbLoadRecords("db/tprTrig.db",     "LOCA=$(AREA), IOC_UNIT=$(IOC_UNIT), INST=1, PORT=trig")

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
#           SETUP AUTOSAVE/RESTORE
# ===========================================
< iocBoot/common/init_restore_soft.cmd

# ===========================================
#           ARCHIVER FILES
# ===========================================
system("cp $(TOP)/archive/$(IOC).archive $(IOC_DATA)/$(IOC)/archive")

# ===========================================
#       LOAD LCLS1 (MR) or LCLS2 CONFIG 
# ===========================================
< iocBoot/common/blenCommon$(BLEN_VERSION).cmd
