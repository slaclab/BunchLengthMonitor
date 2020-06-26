from __future__ import print_function

import os

import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtGui

from pydm import Display

left_lbl = 'ADC Counts / 2'
btm_lbl = 'nanoseconds'

RAW = 0
INT = 1

class CalPlotCtx(pg.ViewBox, QtCore.QObject):
    """ Implements a custom right click menu for Calibration plots """
    y_src_changed = QtCore.Signal(int)

    def __init__(self, parent=None):
        super(CalPlotCtx, self).__init__(parent)
        self.menu = None

    def raiseContextMenu(self, ev):
        if self.menu is None:
            self.menu = QtGui.QMenu()
            self.y_datasrc = QtGui.QMenu("Y Data Source")
            rwf = QtGui.QAction("Raw Waveform", self.y_datasrc)
            iwf = QtGui.QAction("Integration Window Waveform", self.y_datasrc)
            rwf.triggered.connect(self.emit_ychange, RAW)
            iwf.triggered.connect(self.emit_ychange, INT)
            self.y_datasrc.addAction(rwf)
            self.y_datasrc.addAction(iwf)
            self.menu.addMenu(y_datasrc)
        return self.menu

    def emit_ychange(self, wf):
        self.y_src_changed.emit(wf)
        print("Emitted y_src_changed")

class BlenCalPlot(pg.PlotWidget):
    """
    BlenCalibrationPlot implements features useful only for BLEN Calibration.
    We directly subclass pyqtgraph PlotWidget to create our own custom context menu.
    """
   def __init__(self, parent=None):
        super(BlenCalPlot, self).__init__(parent)


class BLENExpert(Display):

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.setup_plots()

    def setup_plots(self):
        """
        self.ui.wfpARawPlusWeight.plotItem.setLabels(
        left = left_lbl,
        bottom = btm_lbl)

        self.ui.wfpBRawPlusWeight.plotItem.setLabels(
        left = left_lbl,
        bottom = btm_lbl)
        """
        main_layout = QtGui.QVBoxLayout()
        self.setLayout(main_layout)

        self.wfpA = BlenCalPlot()
        main_layout.addWidget(wfpA)

    def ui_filename(self):
        pass

    def ui_filepath(self):
        return os.path.join(os.path.dirname(os.path.realpath(__file__)), self.ui_filename())

    def y_changed(self, wf):
        print("Changing waveform: {}".format("RAW" if wf == RAW else "INT"))
