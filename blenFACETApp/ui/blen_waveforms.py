from os import path
from pydm import Display

class BLENWaveforms(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENWaveforms, self).__init__(parent=parent, args=args, macros=macros)
        self.setup_plots()

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
        return path.join(path.dirname(path.realpath(__file__)), self.ui_filename())
