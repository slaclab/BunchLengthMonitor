# ===========================================
#               DB LOADING
# ===========================================

# Manually created yCPSWasyn records
dbLoadRecords("db/blenLCLS2.db", "P=BLEN:${AREA}:${POS}:${INST}A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blenLCLS2.db", "P=BLEN:${AREA}:${POS}:${INST}B, PORT=cpsw, AMC=1")

# Filter control
dbLoadRecords("db/statusBit.db", "P=$(AREA):$(POS), P0=$(AREA)$(POS):AMC0, P1=$(AREA):$(POS):AMC1")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=AIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BIMAX, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=ARAW, SINK_SIZE=1, LNK=''")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BRAW, SINK_SIZE=1, LNK=''")
