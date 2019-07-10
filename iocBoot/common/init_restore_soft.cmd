#==============================================================
#
#  Abs:  Autosave initalization (for a soft IOC)
#
#  Name: init_restore_soft.cmd    
#
#  Facility:  LCLS CAMAC Controls
#
#  Auth: 27-Jan-2011, Kristi Luchini  (LUCHINI)
#  Rev:  dd-mmm-yyyy, Reviewer's Name (USERNAME)
#--------------------------------------------------------------
#  Mod:
#        dd-mmm-yyyy, Reviewer's Name (USERNAME)
#          comment
#
#==============================================================
#
save_restoreSet_Debug(0)

# Specify where request and save_restore files can be found
set_requestfile_path("${IOC_DATA}/${IOC}/autosave-req")
set_requestfile_path("${TOP}/autosave", "")
set_requestfile_path("${TOP}/iocBoot/${IOC}", "")
set_savefile_path("${IOC_DATA}/${IOC}/autosave")

# Status-PV prefix, so save_restore can find its status PVs.
save_restoreSet_status_prefix("${IOC_NAME}:")

# Load bumpless reboot status database
dbLoadRecords("db/save_restoreStatus.db","P=${IOC_NAME}:")

# Ok to restore a save set that had missing values (no CA connection to PV)?
# Ok to save a file if some CA connections are bad?
save_restoreSet_IncompleteSetsOk(1)

# In the restore operation, a copy of the save file will be written.  The
# file name can look like "auto_settings.sav.bu", and be overwritten every
# reboot, or it can look like "auto_settings.sav_020306-083522" (this is what
# is meant by a dated backup file) and every reboot will write a new copy.
#save_restoreSet_DatedBackupFiles(1)

# Specify what save files should be restored and when.
# Note: up to eight files can be specified for each pass.
set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")
set_pass1_restoreFile("blen_manual.sav")

# Number of sequenced backup files (e.g., 'info_settings.sav0') to write
save_restoreSet_NumSeqFiles(3)

# Time interval between sequenced backups
save_restoreSet_SeqPeriodInSeconds(600)

# Time between failed .sav-file write and the retry.
save_restoreSet_RetrySeconds(60)

# End of script
