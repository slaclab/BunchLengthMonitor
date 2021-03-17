#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "HTR")
epicsEnvSet("POS", "350")
epicsEnvSet("INST", "BZ0H04")
epicsEnvSet("IOC_UNIT", "BL04")
epicsEnvSet("ATCA_SLOT", "6")
epicsEnvSet("BLEN_ASYN_PORT", "ATCA$(ATCA_SLOT)")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/firmware/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsGap.yaml")

epicsEnvSet("FPGA_IP", "10.0.1.106")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenGapDiode.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

dbLoadRecords("db/gap_streams.db", "P=BLEN:$(AREA):$(POS):$(INST)C, PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/gap_streams.db", "P=BLEN:$(AREA):$(POS):$(INST)D, PORT=${BLEN_ASYN_PORT}, AMC=1")


dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)C")
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)D")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)C, AMC=0")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)D, AMC=1")

# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Enforce RTM timing
crossbarControl "FPGA" "$(BLEN_VERSION)"

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("$(EPICS_CA_PUT_LOG_ADDR)")
caPutLogShow(2)

< iocBoot/common/start_restore_soft.cmd
