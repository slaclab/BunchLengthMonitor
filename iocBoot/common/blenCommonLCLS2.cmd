# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Dictionary file for manually defined records
epicsEnvSet("DICT_FILE", "yaml/blenLCLS2.dict")

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/blen.dbd",0,0)
blen_registerRecordDeviceDriver(pdbbase)

# ===========================================
#              DRIVER SETUP
# ===========================================

## Yaml Downloader
DownloadYamlFile("${FPGA_IP}", "${YAML_DIR}")

# Load yaml files do CPSW
cpswLoadYamlFile("${TOP_YAML}", "NetIODev", "", "${FPGA_IP}")
cpswLoadConfigFile("${YAML_CONFIG_FILE}", "mmio", "")

# Driver setup for YCPSWAsyn
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("cpsw", "", "${PREFIX}", "${AUTO_GEN}", "${DICT_FILE}")

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
