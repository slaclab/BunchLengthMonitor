TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================
USR_CXXFLAGS += -std=c++0x
#=====================================================
# Path to "NON EPICS" External PACKAGES: USER INCLUDES
#======================================================
# Support for CPSW
USR_INCLUDES = -I$(BOOST_INCLUDE) -I$(CPSW_FRAMEWORK_INCLUDE) -I$(YAML_INCLUDE)
USR_INCLUDES += -I$(CPSW_DEVICE_LIBRARY_INCLUDE)
USR_INCLUDES += -I$(YAMLREADER_INCLUDE)
USR_INCLUDES += -I$(DEVICELIB_INCLUDE)
#=====================================================

#======================================================
#PATH TO "NON EPICS" EXTERNAL PACKAGES: USER LIBRARIES
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
 

#=============================
# Build the IOC application

PROD_IOC = blenFACET
# blenFACET.dbd will be created and installed
DBD += blenFACET.dbd

# blen.dbd will be made up from these files:
blenFACET_DBD += blenDrv.dbd
blenFACET_DBD += base.dbd
blenFACET_DBD += devIocStats.dbd
# Include dbd files from all support applications:
blenFACET_DBD += caPutLog.dbd
#blen_DBD += $(CEXP_DBDS)
# ycpswasyn and yamlLoader 
blenFACET_DBD += yamlLoader.dbd
blenFACET_DBD += yamlDownloader.dbd
blenFACET_DBD += ycpswasyn.dbd
# Crossbar control
blenFACET_DBD += crossbarControl.dbd
# BSA
blenFACET_DBD += bsaCore.dbd
blenFACET_DBD += bsa.dbd
# For calculated waveforms
blenFACET_DBD += calc.dbd
# For FCOM
blenFACET_DBD += fcomIocshSupport.dbd
blenFACET_DBD += fcomUtil.dbd
blenFACET_DBD += devFcom.dbd
blenFACET_DBD += drvAsynIPPort.dbd
# For TPR Triggers
blenFACET_DBD += tprTriggerAsynDriver.dbd
blenFACET_DBD += tprPatternAsynDriver.dbd

# ================================================================================
# The system command will be mainly used by linux hosted IOCs
# Very useful for changing kernel thread priorities for kernel drivers
# ================================================================================
blenFACET_DBD += system.dbd

blenFACET_DBD += asSupport.dbd
blenFACET_DBD += asyn.dbd

# ========================================
# Required for Qsrv
# ========================================
#blen_DBD += PVAServerRegister.dbd
#blen_DBD += qsrv.dbd
# ========================================


# blen_registerRecordDeviceDriver.cpp derives from blenFACET.dbd
blenFACET_SRCS += blenFACET_registerRecordDeviceDriver.cpp

blenFACET_SRCS += blenIOCFunctions.cpp
#blenFACET_SRCS += cpswStreamBSA.cpp
blenFACET_SRCS += blenBSA.cpp
blenFACET_SRCS += blenFcom.cpp
blenFACET_SRCS += asubWeightXAxis.c
blenFACET_SRCS += asubRWF.c

# Build the main IOC entry point on workstation OSs.
blenFACET_SRCS_DEFAULT += blenFACETMain.cpp
blenFACET_SRCS_vxWorks += -nil-

# =====================================================
# Link in the libraries from other EPICS modules
# =====================================================
# For calculated waveforms
blenFACET_LIBS += calc

# For FCOM
blenFACET_LIBS += fcomUtil fcomIocshSupport fcom
blenFACET_LIBS += udpCommBSD 

# Crossbar control
blenFACET_LIBS += crossbarControl

# TPR trigger
blenFACET_LIBS += tprTrigger
blenFACET_LIBS += tprPattern

# BSA
blenFACET_LIBS += eventBsaSupport
blenFACET_LIBS += BsaCore

# Needed to link in iocAdmin support
blenFACET_LIBS += devIocStats

# Needed to link in autosave support
blenFACET_LIBS += autosave

# Needed to link caPutLog support
blenFACET_LIBS += caPutLog

# Needed to link cexpsh() support
#blen_LIBS += $(CEXP_LIBS)

# Needed to link yamlLoader support
#blen_LIBS += yamlLoader
blenFACET_LIBS += yamlDownloader
blenFACET_LIBS += ycpswasyn
blenFACET_LIBS += yamlLoader

# Add support from base/src/vxWorks if needed
#blen_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Link Asyn library support.
# Should be last for other modules that depend on asyn
blenFACET_LIBS += asyn

# ================================================
# Adding Support for EPICS V4 (i.e. EPICS PVA)
# ================================================
# Link in the code from qsrv
#blen_LIBS += qsrv

# ================================================
# EPICS_BASE_PVA_CORE_LIBS comes from pvAccessCPP 
# and is defined at <>/cfg/CONFIG_PVACCESS_MODULE
# ================================================
blenFACET_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)

# ================================================

# Finally link to the EPICS Base libraries
blenFACET_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

