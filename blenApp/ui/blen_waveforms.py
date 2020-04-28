import os

from PyQt5.QtCore import pyqtSignal, pyqtSlot

import pydm
from pydm import Display

class FilterIndicator(pydm.widgets.byte.PyDMByteIndicator):

    changed = pyqtSignal(int)

    def __init__(self, parent=None):
        super(FilterIndicator, self).__init__(parent=parent)

    def value_changed(self, value):
        super(FilterIndicator, self).value_changed(value)
        self.changed.emit(value)



class BLENWaveforms(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENWaveforms, self).__init__(parent=parent, args=args, macros=macros)

        self.setup_shutters()
        self.setup_plots()

    """
    * Initial Setup
    """

    def setup_shutters(self):
        self.filterA_indicator = FilterIndicator()
        self.filterB_indicator = FilterIndicator()
        pass

    def setup_plots(self):
        self.ui.wfpARawPlusWeight.plotItem.setLabels(
        left='ADC counts',
        bottom='nanoseconds')

        self.ui.wfpBRawPlusWeight.plotItem.setLabels(
        left='ADC counts',
        bottom='nanoseconds')

        self.ui.wfpARawTimesWeight.plotItem.setLabels(
        left='ADC counts',
        bottom='nanoseconds')

        self.ui.wfpBRawTimesWeight.plotItem.setLabels(
        left='ADC counts',
        bottom='nanoseconds')

    def ui_filename(self):
        return 'blen_waveforms.ui'

    def ui_filepath(self):
        return os.path.join(os.path.dirname(os.path.realpath(
            __file__)),
            self.ui_filename())

    """
    * Slots
    """

    @pyqtSlot(int)
    def on_shutter_change(self, new_val):
        pass

    @pyqtSlot()
    def on_shutter_btn_press(self):
        pass
