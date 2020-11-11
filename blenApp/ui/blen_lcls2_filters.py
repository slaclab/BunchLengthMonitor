import os

from epics import PV
from pydm import Display
from pydm.widgets.channel import PyDMChannel

class BLENFilters(Display):
    def __init__(self, parent=None, macros=None):
        super(BLENFilters, self).__init__(parent=parent, macros=macros)

        area = self.macros()["AREA"]
        pos  = self.macros()["POS"]

        # Monitor MoverOnOff for changes.
        self.mvr_on_off_ch = PyDMChannel(
                address="ca://BLEN:{}:{}:MoverOnOffRBV".format(area, pos),
                value_slot = self.update_attn())

        self.mvr_on_off_ch.connect()
        self.mvr_on_off = PV("BLEN:{}:{}:MoverOnOffRBV".format(area, pos))

        self.attn_idx = 0
        self.ui.attnEdit.channel = "BLEN:{}:{}:Attenuation0".format(area, pos)
        self.update_attn()

    def update_attn(self):
        """
        Upon change in the filter configuration, we need to change which
        Attenuation register we are talking to.
        """
        try:
            attn_idx = self.mover_on_off.get()
        except:
            print("Could not get MoverOnOffRBV over CA!")
            self.ui.attnEdit.setEnabled(False)
            return

        # The lower two bits are for AMC0 and AMC1 shutters.
        attn_idx = attn_idx >> 2

        # The change could have just been the shutters. In that case, we're done.
        if self.attn_idx == attn_idx:
            return

        self.ui.attnEdit.channel = "BLEM:{}:{}:Attenuation{}".format(
                self.macros()["AREA"], self.macros()["POS"], attn_idx)

        self.attn_idx = attn_idx
        print("Changed to Attenuation{}".format(attn_idx))


    def ui_filename(self):
        return "blen_lcls2_filters.ui"

    def ui_filepath(self):
        path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(path, self.ui_filename())
