#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "LI24")
epicsEnvSet("POS", "886")
epicsEnvSet("INST", "BL21")
epicsEnvSet("IOC_UNIT", "BL03")

# FPGA IP address for CPSW
epicsEnvSet("FPGA_IP", "10.0.1.107")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):${IOC_UNIT}")

# Which version of the Application to use - "MR" or "LCLS2"
epicsEnvSet(BLEN_VERSION, "LCLS2")

cd ${TOP}

< iocBoot/common/blenCommon.cmd

# ===========================================
#               ASYN MASKS
# ===========================================

# ***********************************
# * Asyn Masks for all Asyn drivers *

#asynSetTraceMask(cpsw, -1, 9)
#asynSetTraceMask(crossbar, -1, 9)
#asynSetTraceMask(trig, -1, 9)
#asynSetTraceMask(pattern, -1, 9)

# ===========================================
#               DB LOADING
# ===========================================


# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================

# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Enforce RTM timing
crossbarControl "FPGA" "${BLEN_VERSION}"

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)
