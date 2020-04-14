# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Dictionary file for manually defined records
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

# ===========================================
#               DB LOADING
# ===========================================

# Manually created yCPSWasyn records
dbLoadRecords("db/blenLCLS2.db", "AREA=${AREA}, POS=${POS}, INST=${INST}A, INST_NUM=A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blenLCLS2.db", "AREA=${AREA}, POS=${POS}, INST=${INST}B, INST_NUM=B, PORT=cpsw, AMC=1")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=AIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=ARAW, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BRAW, SINK_SIZE=1")
