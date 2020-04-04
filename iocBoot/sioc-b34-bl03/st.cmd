#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, position, and instrument names to be used in record names
epicsEnvSet("AREA", "B34")
epicsEnvSet("POS", "300")
epicsEnvSet("INST", "BL03")

# Address of the FCOM network
epicsEnvSet("FCOM_NETWORK", "239.219.8.0")

# TMIT PV to read the value from, by using FCOM
epicsEnvSet("TMIT_PV", "BPMS:B34:300:TMIT")

# FPGA IP address for CPSW
epicsEnvSet("FPGA_IP", "10.0.1.103")

# Port number to send TMIT data to the FPGA
epicsEnvSet("IP_PORT_TMIT", "8195")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):BL03")

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

# This is just for test purposes. Must be deleted before first release.
dbpf BLEN:${AREA}:${POS}:${INST}:TCORE:MODE LCLS1
dbpf BLEN:${AREA}:${POS}:${INST}:CHN0:EVENTCODE 40
dbpf BLEN:${AREA}:${POS}:${INST}:CHN0:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:CHN1:EVENTCODE 40
dbpf BLEN:${AREA}:${POS}:${INST}:CHN1:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRG8:LCLS1DELAY 542
dbpf BLEN:${AREA}:${POS}:${INST}:TRG8:SOURCE "Channel 0"
dbpf BLEN:${AREA}:${POS}:${INST}:TRG7:SOURCE "Channel 0"
dbpf BLEN:${AREA}:${POS}:${INST}:TRG1:SOURCE "Channel 0"
dbpf BLEN:${AREA}:${POS}:${INST}:TRGA:SOURCE "Channel 0"
dbpf BLEN:${AREA}:${POS}:${INST}:TRGD:SOURCE "Channel 0"
dbpf BLEN:${AREA}:${POS}:${INST}:TRG7:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRG8:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRG1:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRGA:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRGD:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRG8:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRG7:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRG1:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRGA:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRGD:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}:TRG6:SOURCE "Channel 1"
dbpf BLEN:${AREA}:${POS}:${INST}:TRG6:LCLS1WIDTH 0
dbpf BLEN:${AREA}:${POS}:${INST}:TRG6:LCLS1ENABLE Enabled
dbpf BLEN:${AREA}:${POS}:${INST}A_AutoRearm 1
dbpf BLEN:${AREA}:${POS}:${INST}B_AutoRearm 1
dbpf BLEN:${AREA}:${POS}:${INST}:SOFTEVSEL0_EVENTCODE 40
dbpf BLEN:${AREA}:${POS}:${INST}:SOFTEVSEL0_ENABLE Enabled

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
