# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# BSA stream name must be identical to definition in yaml file
epicsEnvSet("BSA_STREAM_YAML_NAME", "MrBlenBsaStream")

# ===========================================
#              DRIVER SETUP
# ===========================================

# Load drivers for TPR pattern and crossbarControl
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")
tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "tstream")

# FCOM network address and number of buffers
fcomInit("${FCOM_NETWORK}", "20")

# ===========================================
#               DB LOADING
# ===========================================

# Manually created yCPSWasyn records
dbLoadRecords("db/blenMR.db", "P=BLEN:$(AREA):$(POS), AREA=$(AREA), POS=$(POS), INST=$(INST)A, INST_NUM=A, PORT=$(BLEN_ASYN_PORT), AMC=0")
dbLoadRecords("db/blenMR.db", "P=BLEN:$(AREA):$(POS), AREA=$(AREA), POS=$(POS), INST=$(INST)B, INST_NUM=B, PORT=$(BLEN_ASYN_PORT), AMC=1")

dbLoadRecords("db/mrFPGA.db", "P=BLEN:$(AREA):$(POS), PORT=$(BLEN_ASYN_PORT)")

dbLoadRecords("db/tprPattern.db", "LOCA=${AREA}, IOC_UNIT=${IOC_UNIT}, INST=$(ATCA_SLOT), PORT=pattern")
dbLoadRecords("db/tprTrig.db",    "LOCA=$(AREA), IOC_UNIT=$(IOC_UNIT), INST=$(ATCA_SLOT), PORT=trig")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=AIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=ARAW,  SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BRAW,  SINK_SIZE=1")

# tpr high level PVs
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=00,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=01,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=02,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=03,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=04,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=05,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=06,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=07,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=08,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=09,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=10,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=11,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=12,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=13,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=14,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS0,NN=15,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG15:,PORT=trig")
