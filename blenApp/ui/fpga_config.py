import os, subprocess

from epics import PV

from pydm import Display


class FPGAConfig(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(FPGAConfig, self).__init__(parent, args, macros)

        self.connect_pvs()

        self.ui.tree_gui_btn.clicked.connect(self.handle_tree_gui)

    def connect_pvs(self):
        self.sioc_pv_prefix = 'SIOC:{}:{}'.format(\
                self.macros()['AREA'],
                self.macros()['IOC_UNIT'])

        self.blen_pv_prefix = 'BLEN:{}:{}'.format(\
                self.macros()['AREA'],
                self.macros()['POS'])

        self.cpu = PV('{}:CPU'.format(self.sioc_pv_prefix))
        self.shm = PV('{}:SHM'.format(self.sioc_pv_prefix))
        self.atca_slot = PV('{}:ATCA_SLOT'.format(self.sioc_pv_prefix))

    def handle_tree_gui(self):
        subprocess.Popen(self._command(), shell=True, stderr=subprocess.STDOUT)

    def _command(self):
        """ Creates the TreeGUI command from macros and the environment """
        command = []

        cpu = self.cpu.get()
        shm = self.shm.get()
        atca_slot = self.atca_slot.get()

        p_top = os.environ["PACKAGE_TOP"]
        ioc_data = os.environ["IOC"]

        tree_gui = os.path.join('.', p_top, "cpsw/cpswTreeGUI/current/start.sh")
        backdoor = os.path.join(self.path, "../../yaml/backdoor.tar.gz")

        command.append(tree_gui)
        command.extend(['-c', cpu])
        command.extend(['-S', shm])
        command.extend(['-N', str(atca_slot)])
        command.extend(['-t', backdoor])
        command.extend(['-L', '512'])

        print("\n" + "=" * 64)
        print("Launching cpswTreeGUI with following parameters:")
        # Python slice stride `x::y` take element x and increment iterator by y 
        # We're skipping element 0 since it's the path to TreeGUI's start.sh
        for param, val in zip(command[1::2], command[2::2]):
            print("{}:\t{}".format(param, val))

        print("=" * 64)

        return " ".join(command)


    def ui_filename(self):
        return "fpga_config.ui"

    def ui_filepath(self):
        self.path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(self.path, self.ui_filename())

