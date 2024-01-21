source $EPICS_SETUP/envSet_prodOnDev.bash

pydm -m "AREA=LI11, IOC_UNIT=BL01, INST=BZ11359, POS=359, ATCA_SLOT=4" blen_pyro.ui
