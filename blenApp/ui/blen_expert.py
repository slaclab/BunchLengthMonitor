from os import path
from pydm import Display

class BLENExpert(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.setup_plots()

    def setup_plots(self):
        self.ui.wfpARawPlusWeight.plotItem.setLabels(
        left='ADC counts', 
        bottom='nanoseconds')

        self.ui.wfpBRawPlusWeight.plotItem.setLabels(
        left='ADC counts', 
        bottom='nanoseconds')

    def ui_filename(self):
        return 'blen_expert.ui'

    def ui_filepath(self):
        return path.join(path.dirname(path.realpath(__file__)), self.ui_filename())
