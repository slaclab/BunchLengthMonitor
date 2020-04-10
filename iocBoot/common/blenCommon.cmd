# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# ========================================================
# Support Large Arrays/Waveforms; Number in Bytes
# Please calculate the size of the largest waveform
# that you support in your IOC.  Do not just copy numbers
# from other apps.  This will only lead to an exhaustion
# of resources and problems with your IOC.
# The default maximum size for a channel access array is
# 16K bytes.
# ========================================================
# New in EPICS 7: Auto!

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","AUTO")

# YAML directory
epicsEnvSet("YAML_DIR","${IOC_DATA}/${IOC}/firmware/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","${YAML_DIR}/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "${YAML_DIR}/config/defaults.yaml")


# *********************************************
# **** Environment variables for YCPSWASYN ****

# Use Automatic generation of records from the YAML definition.
# Usually it is 0.
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix, case the previous option is 1
epicsEnvSet("PREFIX","BLEN:${AREA}:${POS}:${INST}_")

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/blen.dbd",0,0)
blen_registerRecordDeviceDriver(pdbbase)

# ===========================================
#              DRIVER SETUP
# ===========================================

# Load drivers for TPR trigger and crossbar control
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")


# ===========================================
#               DB LOADING
# ===========================================

# Records to manipulate waveforms from detectors
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=${POS}, INST=${INST}A")
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=${POS}, INST=${INST}B")
dbLoadRecords("db/processRawWFHeader.db", "AREA=${AREA}, POS=${POS}, INST=${INST}A")
dbLoadRecords("db/processRawWFHeader.db", "AREA=${AREA}, POS=${POS}, INST=${INST}B")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=${POS}, INST=${INST}A")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=${POS}, INST=${INST}B")

# Filter control
dbLoadRecords("db/blenFilterDecoders.db", "AREA=${AREA}, POS=${POS}")
dbLoadRecords("db/blenFilters.db", "AREA=${AREA}, POS=${POS}, INST=${INST}")

epicsEnvSet("PART_PV", "${AREA}:BL01")

# Timing crossbar and trigger
dbLoadRecords("db/tprTrig.db",     "LOCA=${AREA}, IOC_UNIT=BL01, INST=2, PORT=trig")
dbLoadRecords("db/crossbarCtrl.db", "DEV=EVR:${PART_PV}, PORT=crossbar")


#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:${AREA}:${POS}:, PORT=cpsw, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=${IOC_DATA}/${IOC}/firmware/yaml/config/defaults.yaml")

# Automatic initialization
#dbLoadRecords("db/monitorFPGAReboot.db", "P=BLEN:${AREA}:${POS}, KEY=840202")

# **********************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ****
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")

# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< ${ACF_INIT}

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================
< iocBoot/common/init_restore_soft.cmd

# ===========================================
#           ARCHIVER FILES
# ===========================================
system("cp ${TOP}/archive/${IOC}.archive ${IOC_DATA}/${IOC}/archive")

# ===========================================
#          LOAD MR or LCLS2 CONFIG 
# ===========================================
< iocBoot/common/blenCommon$(BLEN_VERSION).cmd
