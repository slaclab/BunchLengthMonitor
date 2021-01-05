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
epicsEnvSet("IOC_UNIT", "BL03")
epicsEnvSet("ATCA_SLOT", "7")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/firmware/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsPyro.yaml")

epicsEnvSet("FPGA_IP", "10.0.1.107")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd


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
