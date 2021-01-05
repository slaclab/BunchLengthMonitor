import os

import pydm
from pydm import Display


left_lbl = 'ADC Counts / 2'
btm_lbl = 'nanoseconds'


class BLENWaveforms(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENWaveforms, self).__init__(
                parent=parent,
                args=args,
                macros=macros)

        self.setup_plots()

    def setup_plots(self):

        self.ui.left_plot.plotItem.setLabels(
        left = left_lbl,
        bottom = btm_lbl)

        self.ui.right_plot.plotItem.setLabels(
        left = left_lbl,
        bottom = btm_lbl)

    def ui_filename(self):
        return 'blen_wf_plot.ui'

    def ui_filepath(self):
        return os.path.join(os.path.dirname(os.path.realpath(
            __file__)),
            self.ui_filename())
