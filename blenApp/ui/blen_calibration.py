from __future__ import print_function

import os

import attr
import ipdb

import pyqtgraph as pg
from qtpy.QtCore import Signal, QObject, QPoint, Qt
from qtpy.QtGui import QColor
from qtpy.QtWidgets import (QAction, QGridLayout, QHBoxLayout, QLabel, QMenu,
                            QTextEdit, QVBoxLayout, QWidget)

from pydm import Display
from pydm.widgets import PyDMLineEdit, PyDMSlider
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
                inst = self.plot.macros["INST"]
                self.instA_menu = QMenu("{}A".format(inst))
                self.instB_menu = QMenu("{}B".format(inst))
            except KeyError:
                raise KeyError("'INST' macro was not defined! Please start this screen with the 'INST' macro!")

            rwfA = QAction("Raw Waveform (Stream0)", self.y_datasrc)
            rwfB = QAction("Raw Waveform (Stream4)", self.y_datasrc)
            rwf_mult_A = QAction("Raw Waveform times Weight Function", self.y_datasrc)
            rwf_mult_B = QAction("Raw Waveform times Weight Function", self.y_datasrc)
            iwfA = QAction("Integration Window Waveform (Stream3)", self.y_datasrc)
            iwfB = QAction("Integration Window Waveform (Stream7)", self.y_datasrc)
            # these lambdas are a workaround for passing arguments to slots
            rwfA.triggered.connect(lambda: self.emit_ychange(WaveformType.RAW, Sensor.A))
            rwfB.triggered.connect(lambda: self.emit_ychange(WaveformType.RAW, Sensor.B))
            rwf_mult_A.triggered.connect(lambda: self.emit_ychange(WaveformType.RAW_TIMES, Sensor.A))
            rwf_mult_B.triggered.connect(lambda: self.emit_ychange(WaveformType.RAW_TIMES, Sensor.B))
            iwfA.triggered.connect(lambda: self.emit_ychange(WaveformType.INT, Sensor.A))
            iwfB.triggered.connect(lambda: self.emit_ychange(WaveformType.INT, Sensor.B))

            self.y_datasrc.addMenu(self.instA_menu)
            self.y_datasrc.addMenu(self.instB_menu)

            self.instA_menu.addAction(rwfA)
            self.instA_menu.addAction(rwf_mult_A)
            self.instB_menu.addAction(rwfB)
            self.instB_menu.addAction(rwf_mult_B)
            self.instA_menu.addAction(iwfA)
            self.instB_menu.addAction(iwfB)

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
    BlenCalPlot is a waveform plot with extra features useful calibration.

    The PyDMWaveformPlot doesn't have the flexibility needed to make a more
    interactive experience.
    We directly subclass pyqtgraph PlotWidget to create our own custom context menu.
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
        self.sensor = sensor
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
                "{}{} {}".format(self.macros["INST"],
                                 self.sensor,
                                 self.wf))

    def _set_data_src(self):
        src_pv_prefix = "ca://BLEN:{}:{}:{}{}".format(
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"],
                self.sensor)

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
    """ A PyDM Slider where the value label is a PyDMLineEdit """
    def __init__(self, macros, parent=None, ch=None):
        super(BlenPyDMSlider, self).__init__(parent)
        self.macros = macros
        self.sensor = ch.split(":")[0]
        self.window_edge = ch.split(":")[-1]
        self.pv = "BLEN:{}:{}:{}{}:{}".format(\
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"],
                self.sensor,
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
        self.pv = "BLEN:{}:{}:{}{}:{}".format(\
                self.macros["AREA"],
                self.macros["POS"],
                self.macros["INST"],
                self.sensor,
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
        self.pos_label = QLabel("Duration Pos-Edge (ns)")

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

    def __init__(self, parent=None, args=None, macros=None):
        super(BLENExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.setWindowTitle(\
                "Bunch Length {} Calibration".format(self.macros()["INST"]))

        self.setFixedSize(1500, 500)
        self.setup_plots()

    def setup_plots(self):
        main_layout = QVBoxLayout()
        plot_layout = QHBoxLayout()
        weight_fn_layout = QHBoxLayout()

        self.wfp0 = BlenCalPlot(self.macros(), Sensor.A, WaveformType.RAW)
        self.wfp1 = BlenCalPlot(self.macros(), Sensor.B, WaveformType.RAW)

        self.wfp0_sliders = BlenWeightFnSliders(macros=self.macros(), parent=self, sensor=Sensor.A)
        self.wfp0.src_changed.connect(self.wfp0_sliders.plot_src_changed)
        self.wfp1_sliders = BlenWeightFnSliders(macros=self.macros(), parent=self, sensor=Sensor.B)
        self.wfp1.src_changed.connect(self.wfp1_sliders.plot_src_changed)

        plot_layout.addWidget(self.wfp0)
        plot_layout.addWidget(self.wfp1)

        weight_fn_layout.addWidget(self.wfp0_sliders)
        weight_fn_layout.addWidget(self.wfp1_sliders)

        self.setLayout(main_layout)
        main_layout.addLayout(weight_fn_layout)
        main_layout.addLayout(plot_layout)

    def ui_filepath(self):
        return None
