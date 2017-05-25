#  -*- Makefile -*-
TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

# EDM Screens to install
# You can override the default installation path.
#INSTALL_LOCATION=

EDL += BunchLength_diode.edl  amcStatus.edl       blenExpert.edl
EDL += blenTrigger.edl        defaults.edl        version.edl
EDL += BunchLength_pyro.edl   blenCoef.edl        blenMode.edl
EDL += daqmuxV2Status.edl     webStatus.edl       blenHelp.edl
EDL += cmnConfig.edl          moverCntl.edl       dspCoreRes.edl
EDL += startEdm_diode.sh      startEdm_pyro.sh

# Install images to be used by EDM (Gif and Png are supported)
# PNG is better and preferred.
#PNGS +=
#GIFS +=

# EDM Screens to install
# If you want to install all screens and are
# lazy use the wildcard method. :)
#EDLS+=$(wildcard *.edl)
#PNGS+=$(wildcard *.png)
#GIFS+=$(wildcard *.gif)


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
