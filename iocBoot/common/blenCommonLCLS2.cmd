# ===========================================
#               DB LOADING
# ===========================================

# Manually created yCPSWasyn records
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS):$(INST)A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blen.db", "P=BLEN:$(AREA):$(POS):$(INST)B, PORT=cpsw, AMC=1")

dbLoadRecords("db/blenLCLS2.db", "P=BLEN:$(AREA):$(POS), P0=$(INST)A, P1=$(INST)B, SCAN=1 second")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=AIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=ARAW, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:$(AREA):$(POS),ATRB=BRAW, SINK_SIZE=1, LNK=''")
