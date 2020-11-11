import os

from qtpy.QtCore import Qt
from qtpy.QtWidgets import QLabel

from epics import PV
from pydm import Display
from pydm.widgets import PyDMLineEdit

class BLENFilters(Display):
    def __init__(self, parent=None, macros=None):
        super(BLENFilters, self).__init__(parent=parent, macros=macros)

        self.area = self.macros()["AREA"]
        self.pos  = self.macros()["POS"]

        # make 16 LineEdit widgets to swap out.
        self.attn_edits = [
            PyDMLineEdit(
                init_channel="ca://BLEN:{}:{}:Attenuation{}".format(
                self.area, self.pos, i))
            for i in range(16)
        ]

        # Set up the filter attenuation widgets.
        self.ui.attnLayout.addStretch(2)

        self.attnLbl = QLabel("Filter Attenuation")
        self.attnLbl.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        self.attnLbl.setStyleSheet("QLabel { font: bold 12pt; }")
        self.ui.attnLayout.addWidget(self.attnLbl)

        for widget in self.attn_edits:
            self.ui.attnLayout.addWidget(widget)
            widget.hide()

        self.ui.attnLayout.addStretch(0.25)

        self.last_attn_idx = 0

        # Monitor MoverOnOff for changes.
        # This seems to work better than PyDMChannel - especially because it
        # actually passes args to the callback.
        self.mvr_pv = PV("BLEN:{}:{}:MoverOnOffRBV".format(self.area, self.pos),
                callback=self.update_attn)
        self.mvr_pv.connect()


    def update_attn(self, value=0, **kwargs):
        """
        Upon change in the filter configuration, we need to change which
        Attenuation register we are talking to.
        """
        # The lower two bits are for AMC0 and AMC1 shutters.
        attn_idx = value >> 2

        self.attn_edits[self.last_attn_idx].hide()
        self.attn_edits[attn_idx].show()

        self.attnLbl.setText("Filter Attenuation[{}] ".format(attn_idx))


        self.last_attn_idx = attn_idx
        print("Changed to Attenuation{}".format(attn_idx))


    def ui_filename(self):
        return "blen_lcls2_filters.ui"

    def ui_filepath(self):
        path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(path, self.ui_filename())
