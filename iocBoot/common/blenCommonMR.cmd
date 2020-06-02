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
dbLoadRecords("db/blenMR.db", "AREA=${AREA}, POS=${POS}, INST=${INST}A, INST_NUM=A, PORT=cpsw, AMC=0")
dbLoadRecords("db/blenMR.db", "AREA=${AREA}, POS=${POS}, INST=${INST}B, INST_NUM=B, PORT=cpsw, AMC=1")

# Filter control
dbLoadRecords("db/blenFilterDecoders.db", "AREA=${AREA}, POS=${POS}")
dbLoadRecords("db/blenFilters.db", "AREA=${AREA}, POS=${POS}, INST=${INST}")

dbLoadRecords("db/crossbarCtrl.db", "DEV=EVR:$(PART_PV), PORT=crossbar")
dbLoadRecords("db/tprPattern.db",  "LOCA=${AREA}, IOC_UNIT=${IOC_UNIT}, INST=2, PORT=pattern")

# BSA records
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=AIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BIMAX, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=ARAW, SINK_SIZE=1")
dbLoadRecords("db/Bsa.db", "DEVICE=BLEN:${AREA}:${POS},ATRB=BRAW, SINK_SIZE=1")
