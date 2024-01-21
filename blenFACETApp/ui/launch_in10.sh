source $EPICS_SETUP/envSet_prodOnDev.bash

pydm -m "AREA=IN10, IOC_UNIT=BL01, INST=BZ10596, POS=596, ATCA_SLOT=5" blen_waveforms.ui
