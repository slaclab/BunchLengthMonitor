#!../../bin/linuxRT-x86_64/blen

## You may have to change blen to something else
## everywhere it appears in this file

< envPaths


# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# ****************************************************
# **** Environment variables for BCM on YCPSWAsyn ****

# Support Large Arrays/Waveforms; Number in Bytes
# Please calculate the size of the largest waveform
# that you support in your IOC.  Do not just copy numbers
# from other apps.  This will only lead to an exhaustion
# of resources and problems with your IOC.
# The default maximum size for a channel access array is
# 16K bytes.
# Uncomment and set appropriate size for your application:
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "21000000")

# PV prefix
epicsEnvSet("PREFIX","VIOC:LI02:BL01")
epicsEnvSet("CPSW_PORT","S6")

# Yaml File
epicsEnvSet("YAML_FILE", "yaml/AmcCarrierBlen_project.yaml/000TopLevel.yaml")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.106")

# AMC slot (0 or 1)
epicsEnvSet("AMC","1")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/blen_00000016.dict")

# *********************************************
# **** Environment variables for IOC Admin ****

epicsEnvSet(IOC_NAME,"VIOC:LI02:BL01")


cd ${TOP}

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/blen.dbd",0,0)
blen_registerRecordDeviceDriver(pdbbase)


# ===========================================
#              DRIVER SETUP
# ===========================================

# ===================================================================================================================
# Driver setup and initialization for YCPSWAsyn
# ===================================================================================================================

## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Yaml Doc,                  # Path to the YAML file
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    IP Address,                # OPTIONAL: Target FPGA IP Address. If not given it is taken from the YAML file
#    Record name Prefix,        # Record name prefix
#    Record name Length Max,    # Record name maximum length (must be greater than lenght of prefix + 4)
# ==========================================================================================================

YCPSWASYNConfig("${CPSW_PORT}", "${YAML_FILE}", "", "${FPGA_IP}", "${PREFIX}", 40, "${AUTO_GEN}", "${DICT_FILE}")

# =====================================================================
# End: Configure YCPSW asyn port driver
# =====================================================================

# ===========================================
#               ASYN MASKS
# ===========================================

# **********************************
# **** Asyn Masks for YCPSWAsyn ****

#asynSetTraceMask(${PORT},, -1, 9)




# ===========================================
#               DB LOADING
# ===========================================

# ***************************
# **** Load YCPSWAsyn db ****

## Load record instances

# Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${PREFIX}, PORT=${CPSW_PORT}, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=yaml/default_blen_float.yaml")

# Manually create records
dbLoadRecords("db/blen.db", "P=${PREFIX}, PORT=${CPSW_PORT}, AMC=${AMC}")

# Automatic initialization
dbLoadRecords("db/monitorFPGAReboot.db", "P=${PREFIX}, KEY=-66686157")

# **********************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ****
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")


# *******************************************
# **** Load database for autosave status ****

dbLoadRecords("db/save_restoreStatus.db", "P=${IOC_NAME}:")

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================

# If all PVs don't connect continue anyway
save_restoreSet_IncompleteSetsOk(1)

# created save/restore backup files with date string
# useful for recovery.
save_restoreSet_DatedBackupFiles(1)

# Where to find the list of PVs to save
# Where "/data" is an NFS mount point setup when linuxRT target
# boots up.
set_requestfile_path("/data/${IOC}/autosave-req")

# Where to write the save files that will be used to restore
set_savefile_path("/data/${IOC}/autosave")

# Prefix that is use to update save/restore status database
# records
save_restoreSet_UseStatusPVs(1)
save_restoreSet_status_prefix("${IOC_NAME}:")

## Restore datasets
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")


# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< ${ACF_INIT}


# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)


# Start autosave routines to save our data
# optional, needed if the IOC takes a very long time to boot.
#epicsThreadSleep( 1.0)

cd("/data/${IOC}/autosave-req")
iocshCmd("makeAutosaveFiles")
cd ${TOP}

# Start the save_restore task
# save changes on change, but no faster
# than every 5 seconds.
# Note: the last arg cannot be set to 0
create_monitor_set("info_positions.req", 5 )
create_monitor_set("info_settings.req" , 30 )


# ************************************************************
# **** System command for Temperature Chassis on Ethercat ****
# Setup Real-time priorities after iocInit for driver threads
system("/bin/su root -c `pwd`/rtPrioritySetup.cmd")
