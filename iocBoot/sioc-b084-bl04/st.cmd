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
epicsEnvSet("BLEN_ASYN_PORT", "ATCA7")

epicsEnvSet("TEMP_IOC", "SIOC:B084:IM03")
epicsEnvSet("TEMP_PY_SRC","$(TEMP_IOC):4:INPUT2:VALUE")
epicsEnvSet("TEMP_NY_SRC","$(TEMP_IOC):5:INPUT2:VALUE")
epicsEnvSet("TEMP_PX_SRC","$(TEMP_IOC):4:INPUT1:VALUE")
epicsEnvSet("TEMP_NX_SRC","$(TEMP_IOC):5:INPUT1:VALUE")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsGap.yaml")

epicsEnvSet("FPGA_IP", "10.0.1.106")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

# Additional Waveform containers for ch1 raw data on AMC0, AMC1
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=0, SENS=1")
dbLoadRecords("db/data_streams.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}, AMC=1, SENS=1")

dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=0, SENS=1")
dbLoadRecords("db/FPGAsensor.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT), AMC=1, SENS=1")


# WeightFunction calculations supporting additio of ch1 on AMC0, AMC1
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), SENS=1, AMC=0")
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), SENS=1, AMC=1")

# Num-sample <--> Time conversion Records supporting ch1 on AMC0, AMC1.
# Parameterized by per-AMC frequency counter (clock).
#dbLoadRecords("db/blen_gap_weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)C, AMC=0, CLK_INST=$(INST)A")
#dbLoadRecords("db/blen_gap_weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)D, AMC=1, CLK_INST=$(INST)B")
dbLoadRecords("db/weightFunctionSensor.db", "AREA=$(AREA), POS=$(POS), INST=1, AMC=0")
dbLoadRecords("db/weightFunctionSensor.db", "AREA=$(AREA), POS=$(POS), INST=1, AMC=1")

# Parse IP address
#should be moved to common
dbLoadRecords("db/ipAddr.db", "P=BLEN:$(AREA):$(POS), SRC=ServerRemoteIp")

# Temperature sensors
dbLoadRecords("db/tempProcess.db","P=BLEN:$(AREA):$(POS), R=TempPY, SRC=$(TEMP_PY_SRC)")
dbLoadRecords("db/tempProcess.db","P=BLEN:$(AREA):$(POS), R=TempNY, SRC=$(TEMP_NY_SRC)")
dbLoadRecords("db/tempProcess.db","P=BLEN:$(AREA):$(POS), R=TempPX, SRC=$(TEMP_PX_SRC)")
dbLoadRecords("db/tempProcess.db","P=BLEN:$(AREA):$(POS), R=TempNX, SRC=$(TEMP_NX_SRC)")

# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Enforce RTM timing
#crossbarControl "FPGA" "$(BLEN_VERSION)"
crossbarControl("FPGA", "BP")

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("$(EPICS_CA_PUT_LOG_ADDR)")
caPutLogShow(2)

< iocBoot/common/start_restore_soft.cmd
