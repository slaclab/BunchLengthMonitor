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

dbLoadRecords("db/pyroFilters.db", "P=BLEN:$(AREA):$(POS)")
dbLoadRecords("db/pyroShutter.db", "P=BLEN:$(AREA):$(POS)")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=BLEN:$(AREA):$(POS), SRC=ServerRemoteIp")

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
