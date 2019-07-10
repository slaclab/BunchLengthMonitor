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
# Uncomment and set appropriate size for your application:

# This IOC provides waveforms with the maximum size of 2800 DBR_TIME_DOUBLE
# itens. For 64 bits systems it corresponds to 12 bytes per item.
# 2800 * 12 = 33600.
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","34000")

# YAML directory
epicsEnvSet("YAML_DIR","${IOC_DATA}/${IOC}/firmware/yaml")
#epicsEnvSet("YAML_DIR","${IOC_DATA}/${IOC}/firmware/marcio")
# Yaml File
epicsEnvSet("TOP_YAML","${YAML_DIR}/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "${YAML_DIR}/config/defaults.yaml")
#epicsEnvSet("YAML_CONFIG_FILE", "${IOC_DATA}/${IOC}/firmware/yaml/config/defaults.yaml")

# BSA stream name must be identical to definition in yaml file
epicsEnvSet("BSA_STREAM_YAML_NAME", "MrBlenBsaStream")

# *********************************************
# **** Environment variables for YCPSWASYN ****

# Use Automatic generation of records from the YAML definition.
# Usually it is 0.
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix, case the previous option is 1
epicsEnvSet("PREFIX","BLEN:${AREA}:${POS}:${INST}_")

# Dictionary file for manually defined records
epicsEnvSet("DICT_FILE", "yaml/blenMR.dict")

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
DownloadYamlFile("${FPGA_IP}", "${YAML_DIR}")

# Load yaml files do CPSW
cpswLoadYamlFile("${TOP_YAML}", "NetIODev", "", "${FPGA_IP}")
cpswLoadConfigFile("${YAML_CONFIG_FILE}", "mmio", "")

# Driver setup for YCPSWAsyn
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("cpsw", "", "${PREFIX}", "${AUTO_GEN}", "${DICT_FILE}")

# Load drivers for TPR trigger, pattern, and crossbar control
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")
tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "tstream")

# FCOM network address and number of buffers
fcomInit("${FCOM_NETWORK}", "20")

# ===========================================
#               DB LOADING
# ===========================================

# Manually created yCPSWasyn records
dbLoadRecords("db/blenMR.db", "AREA=${AREA}, POS=${POS}:, INST=${INST}A, INST_NUM=A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blenMR.db", "AREA=${AREA}, POS=${POS}:, INST=${INST}B, INST_NUM=B, PORT=cpsw, AMC=1")

# Switch on/off stream data from FPGA
dbLoadRecords("db/streamControl.db", "AREA=${AREA}, POS=${POS}, INST=${INST}")

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

# Timing crossbar, pattern, and trigger
dbLoadRecords("db/tprTrig.db",     "LOCA=${AREA}, IOC_UNIT=BL01, INST=2, PORT=trig")
dbLoadRecords("db/tprPattern.db", "DEV=${IOC_NAME}, PORT=pattern")
dbLoadRecords("db/crossbarCtrl.db", "DEV=EVR:${PART_PV}, PORT=crossbar")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=AIMAX")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BIMAX")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=ARAW")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BRAW")

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:${AREA}:${POS}:, PORT=cpsw, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=$IOC_DATA/${IOC_NAME}/firmware/yaml/config/defaults.yaml")

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
