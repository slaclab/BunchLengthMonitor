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
ifeq ($(T_A),linuxRT-x86_64)
   PROD_IOC = blen
   DBD = blen.dbd
#PROD_IOC = blen
# blen.dbd will be created and installed
#DBD += blen.dbd

# blen.dbd will be made up from these files:
blen_DBD += blenDrv.dbd
blen_DBD += base.dbd
blen_DBD += devIocStats.dbd
# Include dbd files from all support applications:
blen_DBD += caPutLog.dbd
#blen_DBD += $(CEXP_DBDS)
# ycpswasyn and yamlLoader 
blen_DBD += yamlLoader.dbd
blen_DBD += yamlDownloader.dbd
blen_DBD += ycpswasyn.dbd
# Crossbar control
blen_DBD += crossbarControl.dbd
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
# For TPR Triggers
blen_DBD += tprTriggerAsynDriver.dbd
blen_DBD += tprPatternAsynDriver.dbd

# ================================================================================
# The system command will be mainly used by linux hosted IOCs
# Very useful for changing kernel thread priorities for kernel drivers
# ================================================================================
blen_DBD += system.dbd

blen_DBD += asSupport.dbd
blen_DBD += asyn.dbd

# ========================================
# Required for Qsrv
# ========================================
#blen_DBD += PVAServerRegister.dbd
#blen_DBD += qsrv.dbd
# ========================================


# blen_registerRecordDeviceDriver.cpp derives from blen.dbd
blen_SRCS += blen_registerRecordDeviceDriver.cpp

blen_SRCS += blenIOCFunctions.cpp
blen_SRCS += cpswStreamBSA.cpp
blen_SRCS += blenBSA.cpp
blen_SRCS += blenFcom.cpp
blen_SRCS += asubWeightXAxis.c
blen_SRCS += asubRWF.c

# Build the main IOC entry point on workstation OSs.
blen_SRCS_DEFAULT += blenMain.cpp
blen_SRCS_vxWorks += -nil-

# =====================================================
# Link in the libraries from other EPICS modules
# =====================================================
# For calculated waveforms
blen_LIBS += calc

# For FCOM
blen_LIBS += fcomUtil fcomIocshSupport fcom
blen_LIBS += udpCommBSD 

# Crossbar control
blen_LIBS += crossbarControl

# TPR trigger
blen_LIBS += tprTrigger
blen_LIBS += tprPattern

# BSA
blen_LIBS += eventBsaSupport
blen_LIBS += BsaCore

# Needed to link in iocAdmin support
blen_LIBS += devIocStats

# Needed to link in autosave support
blen_LIBS += autosave

# Needed to link caPutLog support
blen_LIBS += caPutLog

# Needed to link cexpsh() support
#blen_LIBS += $(CEXP_LIBS)

# Needed to link yamlLoader support
#blen_LIBS += yamlLoader
blen_LIBS += yamlDownloader
blen_LIBS += ycpswasyn
blen_LIBS += yamlLoader

# Add support from base/src/vxWorks if needed
#blen_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Link Asyn library support.
# Should be last for other modules that depend on asyn
blen_LIBS += asyn

# ================================================
# Adding Support for EPICS V4 (i.e. EPICS PVA)
# ================================================
# Link in the code from qsrv
#blen_LIBS += qsrv

# ================================================
# EPICS_BASE_PVA_CORE_LIBS comes from pvAccessCPP 
# and is defined at <>/cfg/CONFIG_PVACCESS_MODULE
# ================================================
blen_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)

# ================================================

# Finally link to the EPICS Base libraries
blen_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================
endif

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

