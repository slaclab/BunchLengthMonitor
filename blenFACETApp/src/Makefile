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
   PROD_IOC = blen_FACET
   DBD = blen_FACET.dbd #Required by blen_registerRecordDeviceDriver.cpp 
#PROD_IOC = blen_FACET
# blen_FACET.dbd will be created and installed
#DBD += blen_FACET.dbd

# blen_FACET.dbd will be made up from these files:
blen_FACET_DBD += blenDrv.dbd
blen_FACET_DBD += base.dbd
blen_FACET_DBD += devIocStats.dbd
# Include dbd files from all support applications:
blen_FACET_DBD += caPutLog.dbd
#blen_FACET_DBD += $(CEXP_DBDS)
# ycpswasyn and yamlLoader 
blen_FACET_DBD += yamlLoader.dbd
blen_FACET_DBD += yamlDownloader.dbd
blen_FACET_DBD += ycpswasyn.dbd
# Crossbar control
blen_FACET_DBD += crossbarControl.dbd
# BSA
blen_FACET_DBD += bsaCore.dbd
blen_FACET_DBD += bsa.dbd
# For calculated waveforms
blen_FACET_DBD += calc.dbd
# For FCOM
blen_FACET_DBD += fcomIocshSupport.dbd
blen_FACET_DBD += fcomUtil.dbd
blen_FACET_DBD += devFcom.dbd
blen_FACET_DBD += drvAsynIPPort.dbd
# For TPR Triggers
blen_FACET_DBD += tprTriggerAsynDriver.dbd
blen_FACET_DBD += tprPatternAsynDriver.dbd

# ================================================================================
# The system command will be mainly used by linux hosted IOCs
# Very useful for changing kernel thread priorities for kernel drivers
# ================================================================================
blen_FACET_DBD += system.dbd

blen_FACET_DBD += asSupport.dbd
blen_FACET_DBD += asyn.dbd

# ========================================
# Required for Qsrv
# ========================================
#blen_FACET_DBD += PVAServerRegister.dbd
#blen_FACET_DBD += qsrv.dbd
# ========================================


# blen_FACET_registerRecordDeviceDriver.cpp derives from blen.dbd
blen_FACET_SRCS += blen_FACET_registerRecordDeviceDriver.cpp

blen_FACET_SRCS += blenIOCFunctions.cpp
blen_FACET_SRCS += cpswStreamBSA.cpp
blen_FACET_SRCS += blenBSA.cpp
blen_FACET_SRCS += blenFcom.cpp
blen_FACET_SRCS += asubWeightXAxis.c
blen_FACET_SRCS += asubRWF.c

# Build the main IOC entry point on workstation OSs.
blen_FACET_SRCS_DEFAULT += blenMain.cpp
blen_FACET_SRCS_vxWorks += -nil-

# =====================================================
# Link in the libraries from other EPICS modules
# =====================================================
# For calculated waveforms
blen_FACET_LIBS += calc

# For FCOM
blen_FACET_LIBS += fcomUtil fcomIocshSupport fcom
blen_FACET_LIBS += udpCommBSD 

# Crossbar control
blen_FACET_LIBS += crossbarControl

# TPR trigger
blen_FACET_LIBS += tprTrigger
blen_FACET_LIBS += tprPattern

# BSA
blen_FACET_LIBS += eventBsaSupport
blen_FACET_LIBS += BsaCore

# Needed to link in iocAdmin support
blen_FACET_LIBS += devIocStats

# Needed to link in autosave support
blen_FACET_LIBS += autosave

# Needed to link caPutLog support
blen_FACET_LIBS += caPutLog

# Needed to link cexpsh() support
#blen_FACET_LIBS += $(CEXP_LIBS)

# Needed to link yamlLoader support
#blen_FACET_LIBS += yamlLoader
blen_FACET_LIBS += yamlDownloader
blen_FACET_LIBS += ycpswasyn
blen_FACET_LIBS += yamlLoader

# Add support from base/src/vxWorks if needed
#blen_FACET_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Link Asyn library support.
# Should be last for other modules that depend on asyn
blen_FACET_LIBS += asyn

# ================================================
# Adding Support for EPICS V4 (i.e. EPICS PVA)
# ================================================
# Link in the code from qsrv
#blen_FACET_LIBS += qsrv

# ================================================
# EPICS_BASE_PVA_CORE_LIBS comes from pvAccessCPP 
# and is defined at <>/cfg/CONFIG_PVACCESS_MODULE
# ================================================
blen_FACET_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)

# ================================================

# Finally link to the EPICS Base libraries
blen_FACET_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================
endif

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

