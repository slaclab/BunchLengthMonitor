# ===========================================
#              BLD SETUP
# ===========================================
 
# make association with BSA channels: bldAssociateBsaChannels(<BSA port name>)
bldAssociateBsaChannels("bsaPort")

# bldAsynDriverConfigure ("<BLD  port name>", "<yaml path to BLD>", "<prefix for the PAYLOAD PV>")
# The register path may be different from the example below. It depends
# on the application. The example, though, will probably fit most applications.
bldAsynDriverConfigure("bldPort", "mmio/AmcCarrierCore/AmcCarrierBsa/Bld", "BLEN:$(AREA):$(POS)")

# Give names for the signals that will participate on BLD.
# These names are shown in the content of the PAYLOAD PV when someone uses
# pvinfo ${TPR_PREFIX}:BLD_PAYLOAD
bldChannelName("AMC0SMOOTHED",          "AMC0 SMOOTHED")
bldChannelName("AMC0BLEN",              "AMC0 BLEN")
bldChannelName("AMC0TMITSTAT",          "AMC0 TMIT STAT")
bldChannelName("AMC0SMOOTHEDFLOAT",     "AMC0 SMOOTHED FLOAT")
bldChannelName("AMC0BLENFLOAT",         "AMC0 BLEN FLOAT")
bldChannelName("AMC0BLSTATUS",          "AMC0 BL STATUS")
bldChannelName("AMC0RAW",               "AMC0 RAW")
bldChannelName("AMC0RAWFLOAT",          "AMC0 RAW FLOAT")

bldChannelName("AMC1SMOOTHED",          "AMC1 SMOOTHED")
bldChannelName("AMC1BLEN",              "AMC1 BLEN")
bldChannelName("AMC1TMITSTAT",          "AMC1 TMIT STAT")
bldChannelName("AMC1SMOOTHEDFLOAT",     "AMC1 SMOOTHED FLOAT")
bldChannelName("AMC1BLENFLOAT",         "AMC1 BLEN FLOAT")
bldChannelName("AMC1BLSTATUS",          "AMC1 BL STATUS")
bldChannelName("AMC1RAW",               "AMC1 RAW")
bldChannelName("AMC1RAWFLOAT",          "AMC1 RAW FLOAT")

# BLD rate control template
# DEV is the DEVICE:AREA:LOCAL of an IOC.
# There's a hidden ${GLOBAL} macro that defaults to TPG:SYS0:1. This matches the
# dev TPG in B34 and also in production. If you are using a different TPG, you
# need to redefine ${GLOBAL} with the correct prefix of the TPG.
# Example: dbLoadRecords("db/bldCtrl.db", "DEV=${TPR_PREFIX},PORT=bldPort,GLOBAL=TPG:B15:1")
# Below we are using the default TPG, so we don't need to provide GLOBAL.
dbLoadRecords("db/bldCtrl.db", "DEV=BLEN:$(AREA):$(POS), PORT=bldPort")

# This database provides access to severity masks and allows enabling/disabling
# each signal individually.
# DEV is the DEVICE:AREA:LOCAL of an IOC.
# SECN is used as part of the PV name. The combination of DEV and SECN macros must
# be unique in the IOC. If you produce an identical pair of DEV and SECN more than
# once, you will have duplicate PVs in the IOC.
# BSAKEY must correspond with what was used with bsaAdd().
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLEN,SECN=BLEN")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0RAW,SECN=RAW")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):0,PORT=bldPort,BSAKEY=AMC0RAWFLOAT,SECN=RAWFLOAT")
 
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1SMOOTHED,SECN=SMOOTHED")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLEN,SECN=BLEN")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1TMITSTAT,SECN=TMITSTAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1SMOOTHEDFLOAT,SECN=SMOOTHEDFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLENFLOAT,SECN=BLENFLOAT")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1BLSTATUS,SECN=BLSTATUS")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1RAW,SECN=RAW")
dbLoadRecords("db/bld.db", "DEV=BLEN:$(AREA):$(POS):1,PORT=bldPort,BSAKEY=AMC1RAWFLOAT,SECN=RAWFLOAT")
