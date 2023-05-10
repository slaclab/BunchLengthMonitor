TOP=../../..
include $(TOP)/configure/CONFIG

REQ += manual.req

# ==================================================
# BLEN DBs common to both MR and LCLS2 platforms
# ==================================================

# ==================================================
# External Dependencies
# ==================================================

# YCPSWAsyn 
# --------------------------------------------------
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
DB_INSTALLS += $(YCPSWASYN)/db/RegisterCommand.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream16.template

DB_INSTALLS += $(YCPSWASYN)/db/saveLoadConfig.db

# Timing (tprTrigger, tprPatter, crossbarControl, event, BSA, BSSS scalr PVs and controls) 
# --------------------------------------------------
DB_INSTALLS += $(TPRTRIGGER)/db/tprTrig.db
DB_INSTALLS += $(TPRTRIGGER)/db/tprDeviceNamePV.db

DB_INSTALLS += $(BSADRIVER)/db/bsa.db

DB_INSTALLS += $(BSADRIVER)/db/bsss.db
DB_INSTALLS += $(BSADRIVER)/db/bsssCtrl.db
DB_INSTALLS += $(BSADRIVER)/db/bsas.db
DB_INSTALLS += $(BSADRIVER)/db/bsasCtrl.db

# IOCAdmin 
# --------------------------------------------------
DB_INSTALLS += $(IOCADMIN)/db/iocAdminSoft.db

DB_INSTALLS += $(IOCADMIN)/db/iocAdminScanMon.db
DB_INSTALLS += $(IOCADMIN)/db/iocScanMonSum.db
DB_INSTALLS += $(IOCADMIN)/db/iocScanMon.db

IOCRELEASE_DB += iocRelease.db

# Autosave 
# --------------------------------------------------
DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db

# ==================================================
# BLEN Application DBs 
# ==================================================

DB += RegDoubleIn.template
DB += RegDoubleOut.template
DB += RegDoubleOutRBV.template

# Main User-visible PVs 
# --------------------------------------------------
DB += blen.db

# DBs containing Expert PVs and other routines
# --------------------------------------------------
DB += commonFPGA.db
DB += FPGAsensor.db
DB += data_streams.db
DB += weightFunctionAmc.db
DB += weightFunctionSensor.db
DB += calculatedWF.db
DB += streamControl.db
DB += iocMeta.db
DB += monitorFPGAReboot.db
DB += bpmSelect.db
DB += ipAddr.db
DB += temperature.template
DB += selectStatus.db
DB += coefScale.db
DB += coefficientScaling.db
DB += sensCalibration.db
DB += coefTransform.db
DB += coefTf.db

include $(TOP)/configure/RULES
