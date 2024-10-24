#!../../bin/linuxRT-x86_64/blen_FACET

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "LI21")
#epicsEnvSet("POS", "265")
epicsEnvSet("POS", "266")
epicsEnvSet("INST", "BL11")

# Address of the FCOM network
epicsEnvSet("FCOM_NETWORK", "239.219.8.0")

# TMIT PV to read the value from, by using FCOM
epicsEnvSet("TMIT_PV", "BPMS:LI21:278:TMIT")

# FPGA IP address for CPSW
epicsEnvSet("FPGA_IP", "10.21.1.102")
# Port number to send TMIT data to the FPGA
epicsEnvSet("IP_PORT_TMIT", "8195")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):BL01")

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
crossbarControl "FPGA" "LCLS1"

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)

# blenConfigure parameters:
# 1 - Station name
# 2 - BSA stream name must be identical to definition in yaml file
# 3 - PV used to get TMIT from FCOM
# 4 - IP address and port to send TMIT information to ATCA
blenConfigure "BLEN:${AREA}:${POS}" "${BSA_STREAM_YAML_NAME}" "${TMIT_PV}" "${FPGA_IP}:${IP_PORT_TMIT}"

< iocBoot/common/start_restore_soft.cmd
