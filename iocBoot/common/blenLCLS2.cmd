# ===========================================
#               DB LOADING
# ===========================================

###############For Pyros
###############dbLoadRecords("db/blenLCLS2.db", "P=BLEN:$(AREA):$(POS), INST0=$(INST)A, INST1=$(INST)B, SCAN=1 second")

dbLoadRecords("db/lcls2FPGA.db", "P=BLEN:$(AREA):$(POS), PORT=${BLEN_ASYN_PORT}") 
dbLoadRecords("db/bpmSelect.db", "P=BLEN:$(AREA):$(POS)")

dbLoadRecords("db/msgStatus.db", "P=BLEN:$(AREA):$(POS)")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=AIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=ARAW, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BRAW, SINK_SIZE=1, LNK=''")

# tpr high level PVs
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=00,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=01,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=02,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=03,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=04,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=05,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=06,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=07,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=08,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=09,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=10,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=11,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=12,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=13,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=14,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=$(ATCA_SLOT),SYS=SYS2,NN=15,DEV_PREFIX=BLEN:$(AREA):$(POS):TRG15:,PORT=trig")
