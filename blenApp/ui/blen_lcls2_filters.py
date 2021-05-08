import os
import threading
import time

from qtpy.QtCore import Qt, Signal, Slot
from qtpy.QtGui import QDoubleValidator
from qtpy.QtWidgets import QLabel, QLineEdit

from epics import PV
from pydm import Display
from pydm.widgets import PyDMLineEdit

bold_lbl_ss = "QLabel { font: 12pt bold; }"

class BLENAttenEdit(QLineEdit):
    """
    A QLineEdit widget that takes in a Control and RBV PV. The widget will
    monitor the RBV asynchronously and update the displayed value. Meant to
    have similar behavior to the cpswTreeGUI ScalVal class but it is specific
    to floating point values.
    """
    _sig_ = Signal(float)

    def __init__(self, ctrl_pv=None, rbv_pv=None, parent=None):
        super(BLENAttenEdit, self).__init__(parent=parent)
        self.ctrl_pv_ = PV(ctrl_pv)
        self.rbv_pv_  = PV(rbv_pv)

        self.ctrl_pv_.connect()
        self.rbv_pv_.connect()

        self.setValidator(QDoubleValidator())

        self.cached_val_ = self.rbv_pv_.get()
        self.update_txt(self.cached_val_)

        self.returnPressed.connect(self.update_val)
        self.editingFinished.connect(self.restore_txt)
        self._sig_.connect(self.update_txt)

        self.rbv_thread_ = threading.Thread(target=self.update_widget)
        self.rbv_thread_.start()


    @Slot()
    def restore_txt(self):
        """ Restore the text into the box if the user cancelled entering. """
        if self.isModified():
            self.update_txt(self.cached_val_)
            self.setModified(False)


    @Slot(float)
    def update_txt(self, val):
        self.setText('{}'.format(val))
        self.cached_val_ = val


    @Slot()
    def update_val(self):
        """ Write out the value to the ctrl PV. """
        self.setModified(False)
        value = float(self.displayText())
        self.ctrl_pv_.put(value)


    def update_widget(self):
        """
        Read the RBV and update text unless widget is being edited.
        This is run in a separate thread.
        """
        while True:
            # The record updates at 500ms so we delay this thread slightly.
            time.sleep(0.7)
            if not self.isModified():
                value = self.rbv_pv_.get()
                self._sig_.emit(value)
                self.cached_val_ = value


class BLENFilters(Display):
    def __init__(self, parent=None, macros=None):
        super(BLENFilters, self).__init__(parent=parent, macros=macros)

        self.area = self.macros()["AREA"]
        self.pos  = self.macros()["POS"]

        # make 16 LineEdit widgets to swap out.
        """
        self.attn_edits = [
            PyDMLineEdit(
                init_channel="ca://BLEN:{}:{}:Attenuation{}".format(
                self.area, self.pos, i))
            for i in range(16)
        ]
        """
        ctrl_pv = "BLEN:{}:{}:Attenuation{}"
        rbv_pv  = "BLEN:{}:{}:Attenuation{}RBV"
        self.attn_edits = [
            BLENAttenEdit(
                ctrl_pv=ctrl_pv.format(self.area, self.pos, i),
                rbv_pv=rbv_pv.format(self.area, self.pos, i))
            for i in range(16)
        ]


        # Set up the filter attenuation widgets.
        self.ui.attnLayout.addStretch(2)

        self.attnLbl = QLabel("Filter Attenuation")
        self.attnLbl.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        self.attnLbl.setStyleSheet(bold_lbl_ss)
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


    def ui_filename(self):
        return "blen_lcls2_filters.ui"


    def ui_filepath(self):
        path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(path, self.ui_filename())
