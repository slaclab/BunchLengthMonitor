TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#========================================

#==================================================================================
# Path to "NON EPICS" External PACKAGES: USER INCLUDES
#==================================================================================
# Support for CPSW
USR_INCLUDES = -I$(BOOST_INCLUDE) -I$(CPSW_FRAMEWORK_INCLUDE) -I$(YAML_INCLUDE)
USR_INCLUDES += -I$(CPSW_DEVICE_LIBRARY_INCLUDE)
USR_INCLUDES += -I$(YAMLREADER_INCLUDE)
#==================================================================================

#======================================================
# PATH TO "NON EPICS" EXTERNAL PACKAGES: USER LIBRARIES
#======================================================
# Support for CPSW
cpsw_DIR = $(CPSW_FRAMEWORK_LIB)
deviceLib_DIR = $(CPSW_DEVICE_LIBRARY_LIB)
boost_system_DIR = $(BOOST_LIB)
yaml-cpp_DIR = $(YAML_LIB)
hpstpr_DIR = $(HPSTPR_LIB)
yamlReader_DIR = $(YAMLREADER_LIB)
# =====================================================

# ======================================================
# LINK "NON EPICS" EXTERNAL PACKAGE LIBRARIES STATICALLY
#=======================================================
USR_LIBS_Linux += yamlReader
USR_LIBS_Linux += deviceLib
USR_LIBS_Linux += cpsw
USR_LIBS_Linux += yaml-cpp
USR_LIBS_Linux += boost_system
USR_LIBS_Linux += hpstpr
#======================================================

# ================================================
# Build the IOC application
# ================================================
# This line will build for HOST + cross target
#PROD_IOC = blen

# These lines will build ONLY for cross target
PROD_IOC_linuxRT-x86_64 = blen
PROD_IOC = $(PROD_IOC_$(T_A))

# blen.dbd will be created and installed
DBD += blen.dbd

# blen.dbd will be made up from these files:
blen_DBD += blenDrv.dbd
blen_DBD += base.dbd
blen_DBD += devIocStats.dbd
blen_DBD += asSupport.dbd
# Include dbd files from all support applications:
blen_DBD += asyn.dbd
blen_DBD += drvAsynIPPort.dbd
blen_DBD += drvAsynSerialPort.dbd
blen_DBD += caPutLog.dbd
blen_DBD += $(CEXP_DBDS)
blen_DBD += crossbarControl.dbd
blen_DBD += tprTriggerAsynDriver.dbd
blen_DBD += tprPatternAsynDriver.dbd

blen_DBD += blenSupport.dbd

# BSA
blen_DBD += bsaCore.dbd
blen_DBD += bsa.dbd

# For calculated waveforms
blen_DBD += calc.dbd

# For FCOM
blen_DBD += fcomIocshSupport.dbd
blen_DBD += fcomUtil.dbd
blen_DBD += devFcom.dbd
blen_DBD += drvAsynIPPort.dbd

# caf: aCalcout record support
blen_DBD += sscanSupport.dbd
blen_DBD += calcSupport.dbd

blen_DBD += ycpswasyn.dbd
blen_DBD += bsaAsynDriver.dbd
blen_DBD += yamlLoader.dbd
blen_DBD += yamlDownloader.dbd

# ================================================================================
# The system command will be mainly used by linux hosted IOCs
# Very useful for changing kernel thread priorities for kernel drivers
# ================================================================================
blen_DBD += system.dbd

# ======================================================================
# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
blen_SRCS += blen_registerRecordDeviceDriver.cpp

blen_SRCS += blenIOCFunctions.cpp
blen_SRCS += cpswStreamBSA.cpp
blen_SRCS += blenBSA.cpp
blen_SRCS += blenFcom.cpp
blen_SRCS += asubWeightXAxis.c
blen_SRCS += asubRWF.c

blen_SRCS_DEFAULT += blenMain.cpp

# ========================================================================
# ========================================================================
# Add locally compiled object code
# For example, subroutines
# ========================================================================
# blen_SRCS += file1.c
# blen_SRCS += file2.c
blen_SRCS += DaqSizeSub.c

# =====================================================
# Link in the libraries other EPICS modules
# =====================================================
blen_LIBS += yamlDownloader
blen_LIBS += ycpswasyn
blen_LIBS += yamlLoader

# caf: Needed to link in aCalcout support
blen_LIBS += calc
blen_LIBS += sscan

# For FCOM
blen_LIBS += fcomUtil fcomIocshSupport fcom
blen_LIBS += udpCommBSD 

# Needed to link in iocAdmin support
blen_LIBS += devIocStats

# Needed to link in autosave support
blen_LIBS += autosave

# Needed to link caPutLog support
blen_LIBS += caPutLog
blen_LIBS += seq pv

# Needed to link cexpsh() support
blen_LIBS += $(CEXP_LIBS)
blen_SYS_LIBS += $(CEXP_SYS_LIBS)

# Needed to link bsaDriver support
blen_LIBS += bsaDriver
bsa_DIR = $(BSA_LIB)
blen_LIBS += bsa
blen_LIBS += eventBsaSupport
blen_LIBS += BsaCore

#Needed for Crossbar control-TprPattern and TprTrigger
blen_LIBS += crossbarControl
blen_LIBS += tprTrigger
blen_LIBS += tprPattern
# API for tprPattern
hpstpr_DIR = $(HPSTPR_LIB)
#blen_LIBS += hpsTpr
# Link Asyn library support.
# Should be last for othe modules that depend on asyn
blen_LIBS += asyn

# =====================================================================


# ======================================================
# Link libraries from EPICS BASE
# =====================================================
blen_LIBS += $(EPICS_BASE_IOC_LIBS)

# ====================================================


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

