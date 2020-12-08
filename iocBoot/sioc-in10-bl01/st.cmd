#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "IN10")
epicsEnvSet("POS", "596")
epicsEnvSet("INST", "BZ10596")
epicsEnvSet("IOC_UNIT", "BL01")
epicsEnvSet("ATCA_SLOT", "5")
epicsEnvSet("BLEN_ASYN_PORT", "ATCA$(ATCA_SLOT)")

# YAML directory
epicsEnvSet("YAML_DIR", "$(IOC_DATA)/$(IOC)/firmware/yaml")

# YAML file
epicsEnvSet("TOP_YAML", "$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsPyro.yaml")

epicsEnvSet("FPGA_IP", "10.0.1.105")

# Address of the FCOM network
epicsEnvSet("FCOM_NETWORK", "239.219.8.0")

# TMIT PV to read the value from, by using FCOM
epicsEnvSet("TMIT_PV", "BPMS:IN10:581:TMIT")

# Port number to send TMIT data to the FPGA
epicsEnvSet("IP_PORT_TMIT", "8195")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):BL01")

# Which version of the Application to use - "FACET", "LCLS1", or "LCLS2"
epicsEnvSet("BLEN_VERSION", "FACET")
epicsEnvSet("DICT_FILE", "yaml/blenMR.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Enforce RTM timing
# We're not in slot 2 so use backplane timing
crossbarControl("FPGA" "BP")

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)

# blenConfigureMR parameters:
# 1 - Station name
# 2 - BSA stream name (must be identical to definition in yaml file)
# 3 - PV used to get TMIT from FCOM
# 4 - IP address and port to send TMIT information to ATCA
blenConfigureMR("BLEN:$(AREA):$(POS)" "$(BSA_STREAM_YAML_NAME)" "$(TMIT_PV)" "$(FPGA_IP):$(IP_PORT_TMIT)")

< iocBoot/common/start_restore_soft.cmd
