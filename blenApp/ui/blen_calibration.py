from __future__ import print_function

import os

import attr

import pyqtgraph as pg
from qtpy.QtCore import Signal, QObject, QPoint, Qt
from qtpy.QtGui import QColor, QFont
from qtpy.QtSvg import QSvgWidget
from qtpy.QtWidgets import (QAction, QDialog, QGridLayout, QHBoxLayout, QLabel,
                            QMenu, QPushButton, QRadioButton, QTextEdit,
                            QVBoxLayout, QWidget)

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

@attr.s(frozen=True)
class WidgetSet(object):
    """ A set of related widgets. """
    plot    = attr.ib()
    sliders = attr.ib()

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
    """ PyDMSlider with a PyDMLineEdit instead of label and only even values """
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
    """ The main calibration display. """
    def __init__(self, parent=None, args=None, macros=None):
        super(BLENExpert, self).__init__(parent=parent, args=args, macros=macros)
        self.inst = self.macros()["INST"]
        self.setWindowTitle("Bunch Length {} Calibration".format(self.inst))

        self.setFixedSize(750, 500)
        self.main_layout = QVBoxLayout()
        self.setLayout(self.main_layout)

        self.setup_instr_select()
        self.setup_plots()

    def setup_instr_select(self):
        self.instr_layout = QHBoxLayout()
        instABtn = QRadioButton()
        instBBtn = QRadioButton()

        instABtn.setText("{}A".format(self.inst))
        instBBtn.setText("{}B".format(self.inst))

        instABtn.setChecked(True)
        instABtn.clicked.connect(self.swap_instrument)
        instBBtn.clicked.connect(self.swap_instrument)

        helpBtn = QPushButton()
        helpBtn.setText("Help")
        helpBtn.clicked.connect(self.open_help)

        self.instr_layout.addWidget(instABtn)
        self.instr_layout.addWidget(instBBtn)
        self.instr_layout.addStretch(10)
        self.instr_layout.addWidget(helpBtn)
        self.main_layout.addLayout(self.instr_layout)

    def setup_plots(self):
        self.plot_layout = QHBoxLayout()
        self.weight_fn_layout = QHBoxLayout()
        self.wfpA = BlenCalPlot(self.macros(), Sensor.A, WaveformType.RAW)
        self.wfpB = BlenCalPlot(self.macros(), Sensor.B, WaveformType.RAW)

        self.wfpA_sliders = BlenWeightFnSliders(macros=self.macros(), parent=self, sensor=Sensor.A)
        self.wfpA.src_changed.connect(self.wfpA_sliders.plot_src_changed)
        self.wfpB_sliders = BlenWeightFnSliders(macros=self.macros(), parent=self, sensor=Sensor.B)
        self.wfpB.src_changed.connect(self.wfpB_sliders.plot_src_changed)

        self.main_layout.addLayout(self.weight_fn_layout)
        self.main_layout.addLayout(self.plot_layout)
        # Only add one plot for now. There's a button that can swap plots out
        self.plot_layout.addWidget(self.wfpA)
        self.weight_fn_layout.addWidget(self.wfpA_sliders)

        self.active_widgets   = WidgetSet(plot = self.wfpA, sliders = self.wfpA_sliders)
        self.inactive_widgets = WidgetSet(plot = self.wfpB, sliders = self.wfpB_sliders)
        self._set_viz()

    def swap_instrument(self):
        """ Swap out the plot and slider widgets """
        tmp = self.active_widgets
        self.active_widgets = self.inactive_widgets
        self.inactive_widgets = tmp

        self.plot_layout.removeWidget(self.inactive_widgets.plot)
        self.plot_layout.addWidget(self.active_widgets.plot)

        self.weight_fn_layout.removeWidget(self.inactive_widgets.sliders)
        self.weight_fn_layout.addWidget(self.active_widgets.sliders)

        self._set_viz()

    def _set_viz(self):
        self.active_widgets.plot.setVisible(True)
        self.active_widgets.sliders.setVisible(True)
        self.inactive_widgets.plot.setVisible(False)
        self.inactive_widgets.sliders.setVisible(False)

    def open_help(self):
        dlg = QDialog(self)
        lo  = QVBoxLayout()

        lbl = QLabel("<b>Explaination of Pre, Mid, and Pos Edges</b>")
        lbl.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        svg = QSvgWidget("help.svg", parent=dlg)
        lo.addWidget(lbl)
        lo.addWidget(svg)

        dlg.setFixedSize(500, 375)
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
