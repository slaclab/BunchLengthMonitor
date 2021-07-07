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
epicsEnvSet("IOC_UNIT", "BL01")
epicsEnvSet("ATCA_SLOT", "4")
epicsEnvSet("BLEN_ASYN_PORT", "ATCA$(ATCA_SLOT)")

# YAML directory
epicsEnvSet("YAML_DIR","$(IOC_DATA)/$(IOC)/yaml")

# Yaml File
epicsEnvSet("TOP_YAML","$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsGap.yaml")

epicsEnvSet("FPGA_IP", "10.0.1.104")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

# Which version of the Application to use - "LCLS1" or "LCLS2"
epicsEnvSet("BLEN_VERSION", "LCLS2")
epicsEnvSet("DICT_FILE", "yaml/blenGapDiode.dict")

cd $(TOP)

< iocBoot/common/blenCommon.cmd

# Additional Waveform containers for ch1 raw data on AMC0, AMC1
dbLoadRecords("db/gap_streams.db", "P=BLEN:$(AREA):$(POS):$(INST)C, PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/gap_streams.db", "P=BLEN:$(AREA):$(POS):$(INST)D, PORT=${BLEN_ASYN_PORT}, AMC=1")

# Additional offset coefficients for AMC0, AMC1 ch1 raw data
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS):$(INST)A, PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/blen_gap_coefI2.db", "P=BLEN:$(AREA):$(POS):$(INST)B, PORT=${BLEN_ASYN_PORT}, AMC=1")

# Additional per-ADC variables for ch1 on AMC0, AMC1
dbLoadRecords("db/blen_gap_DspPreprocConfig.db", "P=BLEN:$(AREA):$(POS):$(INST)C, PORT=${BLEN_ASYN_PORT}, AMC=0")
dbLoadRecords("db/blen_gap_DspPreprocConfig.db", "P=BLEN:$(AREA):$(POS):$(INST)D, PORT=${BLEN_ASYN_PORT}, AMC=1")

# WeightFunction calculations supporting additio of ch1 on AMC0, AMC1
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)C")
dbLoadRecords("db/calculatedWF.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)D")

# Num-sample <--> Time conversion Records supporting ch1 on AMC0, AMC1.
# Parameterized by per-AMC frequency counter (clock).
dbLoadRecords("db/blen_gap_weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)C, AMC=0, CLK_INST=$(INST)A")
dbLoadRecords("db/blen_gap_weightFunctionXAxis.db", "AREA=$(AREA), POS=$(POS), INST=$(INST)D, AMC=1, CLK_INST=$(INST)B")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=BLEN:$(AREA):$(POS), SRC=ServerRemoteIp")

# Pt100 temperature sensor inputs
dbLoadRecords("db/blen_gap_temperatures.db", "P=BLEN:${AREA}:${POS}")

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
