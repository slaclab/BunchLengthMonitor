TOP=../../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

DB_INSTALLS += $(TPRPATTERN)/db/tprPattern.db
DB_INSTALLS += $(CROSSBARCONTROL)/db/crossbarCtrl.db

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

# Main User-visible PVs 
# --------------------------------------------------
DB += blenMR.db


# DBs containing Expert PVs and other routines
# --------------------------------------------------
DB += blenFilters.db
DB += blenFilterDecoders.db
DB += streamControl.db

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

