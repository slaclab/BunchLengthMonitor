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

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsGap.yaml")

## Yaml Downloader
DownloadYamlFile("$(FPGA_IP)", "$(YAML_DIR)")

# Load yaml files for CPSW
cpswLoadYamlFile("$(TOP_YAML)", "NetIODev", "", "$(FPGA_IP)")
cpswLoadConfigFile("$(TOP)/yaml/disable_bld_bsss_bsas.yaml", "mmio/AmcCarrierCore/AmcCarrierBsa")
cpswLoadConfigFile("$(YAML_CONFIG_FILE)", "mmio", "")

# Setup BSA Driver
# add BSA PVs
bsaAdd("AMC0SMOOTHED",     "int32")
bsaAdd("AMC0BLEN",         "uint32")
bsaAdd("AMC0TMITSTAT",     "uint32")
bsaAdd("AMC0SMOOTHEDFLOAT","float32")
bsaAdd("AMC0BLENFLOAT",    "float32")
bsaAdd("AMC0BLSTATUS",     "uint32")
bsaAdd("AMC0RAW",          "int32")
bsaAdd("AMC0RAWFLOAT",     "float32")
bsaAdd("Junk3",             "uint32")
bsaAdd("Junk4",             "uint32")
bsaAdd("Junk5",             "uint32")
bsaAdd("Junk6",             "uint32")
bsaAdd("Junk7",             "uint32")
bsaAdd("Junk8",             "uint32")
bsaAdd("Junk9",             "uint32")
bsaAdd("Junk10",            "uint32")

bsaAdd("AMC1SMOOTHED",     "int32")
bsaAdd("AMC1BLEN",         "uint32")
bsaAdd("AMC1TMITSTAT",     "uint32")
bsaAdd("AMC1SMOOTHEDFLOAT","float32")
bsaAdd("AMC1BLENFLOAT",    "float32")
bsaAdd("AMC1BLSTATUS",     "uint32")
bsaAdd("AMC1RAW",          "int32")
bsaAdd("AMC1RAWFLOAT",     "float32")

# BSA driver for yaml
bsaAsynDriverConfigure("bsaPort", "mmio/AmcCarrierCore/AmcCarrierBsa","strm/AmcCarrierDRAM/dram")

#  Initialize BSSS driver
#  make assoication with BSA channels: bsssAssociateBsaChannels(<BSA port name>)
bsssAssociateBsaChannels("bsaPort")
# confiugre BSSS driver: bsssAsynDriverConfigure(<bsss port>, <register path>)
bsssAsynDriverConfigure("bsssPort", "mmio/AmcCarrierCore/AmcCarrierBsa/Bsss")

epicsEnvSet("BSAS_PREFIX", "BSAS:$(AREA):$(IOC_UNIT):0")

# Make association with BSA channels: bsasAssociateBsaChannels(<BSA port name)
bsasAssociateBsaChannels("bsaPort")

# Configure the 2-D table header titles
# bsasBaseName(<BSA key>, <signal_header>)
# <BSA key> must correspond with what was used with addBsa().
# We've been conventioning to use the DEVICE_PREFIX macro to name header titles.
bsasBaseName("AMC0SMOOTHED",         "BLEN:$(AREA):$(POS):SMOOTHED"     )
bsasBaseName("AMC0BLEN",             "BLEN:$(AREA):$(POS):BLEN"         )
bsasBaseName("AMC0TMITSTAT",         "BLEN:$(AREA):$(POS):TMITSTAT"     )
bsasBaseName("AMC0SMOOTHEDFLOAT",    "BLEN:$(AREA):$(POS):SMOOTHEDFLOAT")
bsasBaseName("AMC0BLENFLOAT",        "BLEN:$(AREA):$(POS):BLENFLOAT"    )
bsasBaseName("AMC0BLSTATUS",         "BLEN:$(AREA):$(POS):BLSTATUS"     )
bsasBaseName("AMC0RAW",              "BLEN:$(AREA):$(POS):RAW"          )
bsasBaseName("AMC0RAWFLOAT",         "BLEN:$(AREA):$(POS):RAWFLOAT"     )
#bsasBaseName("AMC1SMOOTHED",         "BLEN:$(AREA):$(POS):SMOOTHED"     )
#bsasBaseName("AMC1BLEN",             "BLEN:$(AREA):$(POS):BLEN"         )
#bsasBaseName("AMC1TMITSTAT",         "BLEN:$(AREA):$(POS):TMITSTAT"     )
#bsasBaseName("AMC1SMOOTHEDFLOAT",    "BLEN:$(AREA):$(POS):SMOOTHEDFLOAT")
#bsasBaseName("AMC1BLENFLOAT",        "BLEN:$(AREA):$(POS):BLENFLOAT"    )
#bsasBaseName("AMC1BLSTATUS",         "BLEN:$(AREA):$(POS):BLSTATUS"     )

bsasAsynDriverConfigure("bsasPort", "mmio/AmcCarrierCore/AmcCarrierBsa/Bsas", "${BSAS_PREFIX}:SC_DIAG0", "${BSAS_PREFIX}:SC_BSYD", "${BSAS_PREFIX}:SC_HXR", "${BSAS_PREFIX}:SC_SXR")

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

# ======================================
# timing crossbar configuration
# ======================================
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")

## Set MPS Configuration location
# setMpsConfigurationPath(
#   Path)                   # Path to the MPS configuraton TOP directory
setMpsConfigurationPath("${FACILITY_ROOT}/physics/mps_configuration/current/link_node_db")

# *****************************************
# **** Driver setup for L2MPSASYNConfig ****
## Configure asyn port driver
# L2MPSASYNConfig(
#    Port Name)                 # the name given to this port driver
L2MPSASYNConfig("${L2MPSASYN_PORT}", "${APPID}", "${L2MPS_PREFIX}")

dbLoadRecords("db/mps.db","P=${L2MPS_PREFIX},PORT=${L2MPSASYN_PORT}")
#dbLoadRecords("db/mps_blen.db","P=BLEN:$(AREA):$(POS),BAY=0,PORT=${L2MPSASYN_PORT}")  # BLEN Application (Bay 0=Right, 1=Left)

## Set the MpsManager hostname and port number
# L2MPSASYNSetManagerHost(
#    MpsManagerHostName,   # Server hostname
#    MpsManagerPortNumber) # Server port number
#
# In DEV, the MpsManager runs in lcls-dev3, default port number.
L2MPSASYNSetManagerHost("${MPS_MANAGER_HOST}", 1975)



# ===========================================
#               DB LOADING
# ===========================================

# metadata about the IOC
dbLoadRecords("db/iocMeta.db", "AREA=$(AREA),IOC_UNIT=$(IOC_UNIT)")

# main blen database - user facing PVs
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0")
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1")
dbLoadRecords("db/blenUserStatus.db", "P=$(PREFIX)")
dbLoadRecords("db/timingSelection.db", "P=BLEN:$(AREA):$(POS), AREA=$(AREA)")

# Additional offset coefficients for AMC0, AMC1 ch1 raw data
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1")

dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0, SENS=0")
dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1, SENS=0")

# FPGA-related records
#dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0")
#dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1")
#dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0, SENS=0")
#dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1, SENS=0")
#dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT)")
#dbLoadRecords("db/monitorFPGAReboot.db", "P=BLEN:$(AREA):$(POS)")

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

# FPGA-related records
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0")
dbLoadRecords("db/commonFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1")
dbLoadRecords("db/blenConversion.db", "P=$(PREFIX), AMC=0")
dbLoadRecords("db/blenConversion.db", "P=$(PREFIX), AMC=1")
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0, SENS=0")
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1, SENS=0")
dbLoadRecords("db/saveLoadConfig.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT)")
dbLoadRecords("db/monitorFPGAReboot.db", "P=BLEN:$(AREA):$(POS)")

dbLoadRecords("db/lcls2FPGA.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}") 
dbLoadRecords("db/bpmSelect.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/selectStatus.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/sensCalibration.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/sensCalibration.db", "P=BLEN:$(AREA):$(POS), AMC=1")
dbLoadRecords("db/coefficientScaling.db", "P=BLEN:$(AREA):$(POS), AMC=0")
dbLoadRecords("db/coefficientScaling.db", "P=BLEN:$(AREA):$(POS), AMC=1")

dbLoadRecords("db/msgStatus.db", "P=BLEN:$(AREA):$(POS)")

# tpr high level PVs
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=00,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=01,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=02,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=03,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=04,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=05,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=06,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=07,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=08,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=09,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=10,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=11,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=12,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=13,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=14,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS2,NN=15,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG15:,PORT=trig")


# **** Load BSA driver DB ****

dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0BLEN,SECN=BLEN")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0RAW,SECN=RAW")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):0,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC0RAWFLOAT,SECN=RAWFLOAT")

dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1BLEN,SECN=BLEN")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1RAW,SECN=RAW")
dbLoadRecords("db/bsa.db", "DEV=BLEN:$(AREA):$(POS):1,TPR=TPR:$(AREA):$(IOC_UNIT):0,PORT=bsaPort,BSAKEY=AMC1RAWFLOAT,SECN=RAWFLOAT")

# **** Load BSSS Controls DB ****
dbLoadRecords("db/bsssCtrl.db", "DEV=BLEN:$(AREA):$(POS),PORT=bsssPort")

# **** Load BSSS Scalar PV DB ****
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0BLEN,SECN=BLEN")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0RAW,SECN=RAW")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsssPort,BSAKEY=AMC0RAWFLOAT,SECN=RAWFLOAT")

dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1BLEN,SECN=BLEN")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1RAW,SECN=RAW")
dbLoadRecords("db/bsss.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsssPort,BSAKEY=AMC1RAWFLOAT,SECN=RAWFLOAT")

# BSAS rate control template
dbLoadRecords("db/bsasCtrl.db", "AREA=$(AREA),IOC_UNIT=$(IOC_UNIT),IOC_INST=0,PORT=bsasPort")

# **** Load BSAS Scalar PV DB ****
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0BLEN,SECN=BLEN")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0RAW,SECN=RAW")
dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bsasPort,BSAKEY=AMC0RAWFLOAT,SECN=RAWFLOAT")

#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1SMOOTHED,SECN=SMOOTHED")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1BLEN,SECN=BLEN")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1TMITSTAT,SECN=TMITSTAT")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1BLENFLOAT,SECN=BLENFLOAT")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1BLSTATUS,SECN=BLSTATUS")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1RAW,SECN=RAW")
#dbLoadRecords("db/bsas.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bsasPort,BSAKEY=AMC1RAWFLOAT,SECN=RAWFLOAT")

# Timing trigger
# INST = Instance Number (for multiple instances of tprTrigger in an IOC)
# The convention adopted is to set INST to the ATCA slot
dbLoadRecords("db/tprTrig.db",     "LOCA=$(AREA), IOC_UNIT=$(IOC_UNIT), INST=0, PORT=trig")

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

