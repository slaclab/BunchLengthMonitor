from __future__ import print_function

import os

import pyqtgraph as pg
from qtpy.QtCore import Signal, QObject, QPoint, Qt
from qtpy.QtGui import QColor, QFont
from qtpy.QtSvg import QSvgWidget
from qtpy.QtWidgets import (QAction, QDialog, QGridLayout, QHBoxLayout, QLabel,
                            QMenu, QPushButton, QRadioButton, QTextEdit,
                            QVBoxLayout, QWidget)

from pydm import Display
from pydm.widgets import PyDMLineEdit, PyDMSlider, PyDMRelatedDisplayButton
from pydm.widgets.waveformplot import WaveformCurveItem

left_lbl = 'ADC Counts / 2'
btm_lbl = 'nanoseconds'

class WaveformType:
    RAW = "Raw"
    INT = "Integration Window"
    RAW_TIMES = "Raw times Weight Fn"

class Sensor:
    A = "A"
    B = "B"
    C = "C"
    D = "D"

blen_pv = { "x": ":SampTime.VALA", WaveformType.RAW: ":RWF_U16.VALA", WaveformType.INT: ":IWF_U16.VALA",
        WaveformType.RAW_TIMES: "_S_P_WF", "window": "_SCL_VWF.AVAL"}

class CalPlotCtxBox(pg.ViewBox, QObject):
    """ Implements a custom right click menu for Calibration plots """
    y_src_changed = Signal(str, str)
    int_window_changed = Signal(int)
    reset_view = Signal()

    def __init__(self, plot, menuItems=None, parent=None):
        super(CalPlotCtxBox, self).__init__(parent)
        self.plot = plot
        self.menuItems = menuItems
        self.menu = None

    def get_menu(self):
        if self.menu is None:
            self.menu = QMenu()
            self.view_all = QAction("View All", self)
            self.view_all.triggered.connect(self.autoRange)

            self.reset = QAction("Reset View (1 us)", self)
            self.reset.triggered.connect(self.reset_view.emit)

            self.show_int_window = QAction("Show Weight Function")
            self.show_int_window.setCheckable(True)
            self.show_int_window.setChecked(True)
            self.show_int_window.triggered.connect(self.emit_int_window_changed)


            self.y_datasrc = QMenu("Data Source")
            try:
                # The plot INST macro is something like BZ21BA where
                # BZ21B is the MAD name and A is the instr
                sensor = self.plot.macros["INST"][-1]
            except KeyError:
                raise KeyError("'INST' macro was not defined! Please start this screen with the 'INST' macro!")

            rwf = QAction("Raw Waveform (Stream0)", self.y_datasrc)
            rwf_mult = QAction("Raw Waveform times Weight Function", self.y_datasrc)
            iwf = QAction("Integration Window Waveform (Stream3)", self.y_datasrc)
            # PyQt5 requires a workaround for passing arguments to slots.
            # We use lambdas.
            rwf.triggered.connect(lambda: self.emit_ychange(
                WaveformType.RAW, sensor))
            rwf_mult.triggered.connect(lambda: self.emit_ychange(
                WaveformType.RAW_TIMES, sensor))
            iwf.triggered.connect(lambda: self.emit_ychange(
                WaveformType.INT, sensor))

            self.y_datasrc.addAction(rwf)
            self.y_datasrc.addAction(rwf_mult)
            self.y_datasrc.addAction(iwf)

            self.menu.addAction(self.view_all)
            self.menu.addAction(self.reset)
            self.menu.addSeparator()

            self.menu.addMenu(self.y_datasrc)
            self.menu.addAction(self.show_int_window)
        return self.menu

    def raiseContextMenu(self, ev):
        menu = self.get_menu()
        pos = ev.screenPos()
        menu.popup(QPoint(pos.x(), pos.y()))

    def emit_ychange(self, wf, sensor):
        self.y_src_changed.emit(wf, sensor)

    def emit_int_window_changed(self):
        self.int_window_changed.emit(self.show_int_window.isChecked())


class BlenCalPlot(pg.PlotWidget):
    """
    BlenCalPlot is a waveform plot with extra features useful for calibration.

    The PyDMWaveformPlot doesn't have the flexibility needed to make a more
    interactive experience. This class directly subclasses pyqtgraph PlotWidget
    in order to implement a custom right click menu.
    """

    src_changed = Signal(str, str)

    def __init__(self, macros, sensor, wf, parent=None):
        super(BlenCalPlot, self).__init__(parent, viewBox=CalPlotCtxBox(self))
        self.plotItem = self.getPlotItem()
        self.plotItem.hideButtons()
        self.plotItem.vb.y_src_changed.connect(self.y_changed)
        self.plotItem.vb.int_window_changed.connect(self.show_int_window)
        self.plotItem.vb.reset_view.connect(self.reset_view)

        self.macros = macros
        self.sensor = sensor       # Sensor 
        self.wf = wf               # WaveformType 
        self.curve = WaveformCurveItem()
        self.window_curve = WaveformCurveItem(color=QColor("#00ffff"))
        self.curve.data_changed.connect(self.redraw_plot)
        self.window_curve.data_changed.connect(self.redraw_plot)

        self.addItem(self.curve)
        self.addItem(self.window_curve)

        self.setXRange(0, 1000)

        self.label_plot()
        self._set_data_src()


    def y_changed(self, wf, sensor):
        if self.wf == wf and self.sensor == sensor:
            return
        self.wf = wf
        self.label_plot()
        self._set_data_src()
        self.redraw_plot()
        self.reset_view()

    def show_int_window(self, state):
        self.addItem(self.window_curve) if state else self.removeItem(self.window_curve)

    def label_plot(self):
        self.plotItem.setLabels(
                left = left_lbl,
                bottom = btm_lbl)
        self.plotItem.setTitle(
                "{} {}".format(self.macros["INST"],
                                 self.wf))

    def _set_data_src(self):
        src_pv_prefix = "ca://BLEN:{}:{}:{}".format(
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"])

        x_pv = "{}{}".format(src_pv_prefix, blen_pv["x"])
        y_pv = "{}{}".format(src_pv_prefix, blen_pv[self.wf])
        window_pv = "{}{}".format(src_pv_prefix, blen_pv["window"])

        for curve_ch, window_ch in (self.curve.channels(), self.window_curve.channels()):
            try:
                curve_ch.disconnect()
                window_ch.disconnect()
            except AttributeError:
                continue

        self.curve.x_address = x_pv
        self.curve.y_address = y_pv

        self.window_curve.x_address = x_pv
        self.window_curve.y_address = window_pv

        for curve_ch, window_ch in (self.curve.channels(), self.window_curve.channels()):
            curve_ch.connect()
            window_ch.connect()


        self.src_changed.emit(self.wf, self.sensor)

    def redraw_plot(self):
        self.curve.redrawCurve()
        self.window_curve.redrawCurve()

    def reset_view(self):
        # y range might have got a little weird.
        self.enableAutoRange(axis=pg.ViewBox.YAxis)
        self.setXRange(0, 1000)



class BlenPyDMSlider(PyDMSlider):
    """ PyDMSlider with a PyDMLineEdit instead of label and only even values """
    def __init__(self, macros, parent=None, ch=None):
        super(BlenPyDMSlider, self).__init__(parent)
        self.macros = macros
        self.sensor = ch.split(":")[0]
        self.window_edge = ch.split(":")[-1]
        self.pv = "BLEN:{}:{}:{}:{}".format(\
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"],
                self.window_edge)

        self.value_label = PyDMLineEdit(self)
        self.value_label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        self.orientation = Qt.Horizontal
        self.userDefinedLimits = True
        self.showLimitLabels = False
        self.userMinimum = 0
        self.userMaximum = 1000
        self.num_steps = self.userMaximum - self.userMinimum + 1

        # call PyDMSlider's setup again to put our label in the right place
        self.setup_widgets_for_orientation(self.orientation)
        #self.reset_slider_limits()

        self._change_channel()

    def plot_src_changed(self, wf, sensor):
        self.sensor = sensor
        self.pv = "BLEN:{}:{}:{}:{}".format(\
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"],
                self.window_edge)

        self._change_channel()

    def _change_channel(self):
        self.value_label.channel = self.pv
        self.channel = self.pv



class BlenWeightFnSliders(QWidget):
    """ A widget with sliders to control the weight function edges + offset """

    def __init__(self, macros, parent=None, sensor=None):
        super(BlenWeightFnSliders, self).__init__(parent)

        self.macros = macros
        self.sensor = sensor

        self.pre_slider = BlenPyDMSlider(macros, self, ch="{}:TIME_PRE".format(self.sensor))
        self.mid_slider = BlenPyDMSlider(macros, self, ch="{}:TIME_MID".format(self.sensor))
        self.pos_slider = BlenPyDMSlider(macros, self, ch="{}:TIME_POS".format(self.sensor))

        self.pre_label = QLabel("Duration Pre-Edge (ns)")
        self.mid_label = QLabel("Duration Inter-Edge (ns)")
        self.pos_label = QLabel("Duration Post-Edge (ns)")

        self.sliders = [self.pre_slider, self.mid_slider, self.pos_slider]
        self.labels = [self.pre_label, self.mid_label, self.pos_label]


        self.setup_ui()

    def setup_ui(self):
        # set label fonts
        lbl_font = self.pre_label.font()
        lbl_font.setPointSize(11)

        self.layout = QHBoxLayout()
        slider_layouts = [QVBoxLayout() for i in range(3)]

        for lo, label, slider in zip(slider_layouts, self.labels, self.sliders):
            label.setFont(lbl_font)
            label.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            lo.addWidget(label)
            lo.addWidget(slider)
            self.layout.addLayout(lo)

        self.setLayout(self.layout)


    def plot_src_changed(self, wf, inst):
        for slider in self.sliders:
            slider.plot_src_changed(wf, inst)



class BLENExpert(Display):
    """ The main calibration display. """
    def __init__(self, parent=None, args=None, macros=None):
        super(BLENExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.setWindowTitle("Bunch Length {} Calibration".format(
            self.macros()["INST"][:-1]))

        """
        We appended the A or B AMC card to the end of the INST macro in
        the Qt Designer file.
        eg: INST = BZ21BA but the MAD name is actually just BZ21B
        """
        self.mad = self.macros()["INST"][:-1]
        #if (self.macros()["INST"][-1] == 'A'):
        #    self.sensor = Sensor.A
        #else:
        #    self.sensor = Sensor.B
        self.sensor = self.macros()['INST'][-1] # pick off the A,B,C,D channel suffix

        self.setFixedSize(725, 500)
        self.main_layout = QVBoxLayout()
        self.setLayout(self.main_layout)

        self.setup_buttons()
        self.setup_plots()

    def setup_buttons(self):
        self.btn_layout = QHBoxLayout()

        help_btn = QPushButton("Help...")
        help_btn.clicked.connect(self.open_help)

        self.btn_layout.addStretch(10)
        self.btn_layout.addWidget(help_btn)
        self.main_layout.addLayout(self.btn_layout)

    def setup_plots(self):
        self.plot_layout = QHBoxLayout()
        self.weight_fn_layout = QHBoxLayout()
        self.wfp = BlenCalPlot(self.macros(), self.sensor, WaveformType.RAW)

        self.wfp_sliders = BlenWeightFnSliders(macros=self.macros(),
                parent=self, sensor=self.sensor)
        self.wfp.src_changed.connect(self.wfp_sliders.plot_src_changed)

        self.plot_layout.addWidget(self.wfp)
        self.weight_fn_layout.addWidget(self.wfp_sliders)

        self.main_layout.addLayout(self.weight_fn_layout)
        self.main_layout.addLayout(self.plot_layout)

    def open_help(self):
        dlg = QDialog(self)
        lo  = QVBoxLayout()

        lbl = QLabel("<b>Explaination of Pre, Mid, and Post Edges</b>")
        lbl.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        svg = QSvgWidget("help.svg", parent=dlg)
        lo.addWidget(lbl)
        lo.addWidget(svg)

        dlg.setFixedSize(800, 600)
        dlg.setLayout(lo)
        dlg.setWindowTitle("BLEN Calibration Help")
        dlg.setModal(False)

        # if there's already a dialog open we should close it
        try:
            self.dlg.close()
        except:
            pass

        self.dlg = dlg
        self.dlg.show()


    def ui_filepath(self):
        return None
