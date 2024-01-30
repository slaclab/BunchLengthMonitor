TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

REQ += manual.req

#----------------------------------------------------
# Create and install (or just install) into <top>/db
# databases, templates, substitutions like this

# ATCA
## For automatic generated records
DB_INSTALLS += $(YCPSWASYN)/db/ai.template
DB_INSTALLS += $(YCPSWASYN)/db/ao.template
DB_INSTALLS += $(YCPSWASYN)/db/longin.template
DB_INSTALLS += $(YCPSWASYN)/db/longout.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_in.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_out.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_8_in.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_8_out.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_in_float.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_out_float.template
DB_INSTALLS += $(YCPSWASYN)/db/mbbi.template
DB_INSTALLS += $(YCPSWASYN)/db/mbbo.template
DB_INSTALLS += $(YCPSWASYN)/db/bo.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_stream16.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_stream32.template

## For manually created record
DB_INSTALLS += $(YCPSWASYN)/db/RegisterIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayChar.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterCommand.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream16.template
DB_INSTALLS += $(YCPSWASYN)/db/example.substitutions

# For weight function and final result waveforms
DB += calculatedWF.db

# For saving and loading yaml configuration
DB_INSTALLS += $(YCPSWASYN)/db/saveLoadConfig.db

# For automatic initialization (requires saveLoadConfig.db)
DB_INSTALLS += $(YCPSWASYN)/db/monitorFPGAReboot.db

DB += blenMR.db
DB += blenFilters.db
DB += blenFilterDecoders.db
DB += weightFunctionXAxis.db
DB += streamControl.db
DB += processRawWFHeader.db
DB += iocMeta.db
DB += sensCalibration.db
DB += coefScale.db
DB += coefTransform.db
DB += coefTf.db

# Install Database for tprTrigger module
DB_INSTALLS += $(TPRTRIGGER)/db/tprTrig.db
DB_INSTALLS += $(TPRTRIGGER)/db/tprDeviceNamePV.db

# Install Database for tprPattern module
DB_INSTALLS += $(TPRPATTERN)/db/tprPattern.db

# Database for crossbar control
DB_INSTALLS += $(CROSSBARCONTROL)/db/crossbarCtrl.db

# BSA
#DB_INSTALLS += $(EVENT)/db/bsaBLENEdef.db
DB_INSTALLS += $(EVRCLIENT)/db/bsaATTREdef_FACET.db

# Install Common databases needed by All IOCs
# ========================================================
# Install databases from iocAdmin package
# These databases support IOC Health and Monitoring
# ========================================================
DB_INSTALLS += $(IOCADMIN)/db/iocAdminSoft.db
DB_INSTALLS += $(IOCADMIN)/db/iocAdminScanMon.db
IOCRELEASE_DB += iocRelease.db

# Autosave
DB += $(AUTOSAVE)/db/save_restoreStatus.db

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_template = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

