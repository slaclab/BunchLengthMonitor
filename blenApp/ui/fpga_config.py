import os, subprocess

from epics import PV

from pydm import Display


class FPGAConfig(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(FPGAConfig, self).__init__(parent, args, macros)

        self.ui.tree_gui_btn.clicked.connect(self.handle_tree_gui)

    def handle_tree_gui(self):
        try:
            subprocess.check_output(self._command(), shell=True, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            print("Failed to start TreeGUI:")
            print(e.output)


    def _command(self):
        """ Creates the TreeGUI command from macros and the environment """
        command = []
        pv_prefix = "SIOC:{}:{}".format(\
                self.macros()["AREA"],
                self.macros()["IOC_UNIT"])
        if self.macros()["IOC_UNIT"] != "BL01":
            # BL03 is used in dev
            sioc = "sioc-b084-{}".format(\
                    self.macros()["IOC_UNIT"].lower())
        else:
            sioc = "sioc-{}-{}".format(\
                    self.macros()["AREA"].lower(),
                    self.macros()["IOC_UNIT"].lower())

        cpu = PV("{}:CPU".format(pv_prefix)).get()
        shm = PV("{}:SHM".format(pv_prefix)).get()
        slot = PV("{}:ATCA_SLOT".format(pv_prefix)).get()

        p_top = os.environ["PACKAGE_TOP"]
        ioc_data = os.environ["IOC"]

        tree_gui = os.path.join('.', p_top, "cpsw/cpswTreeGUI/current/start.sh")
        backdoor = os.path.join(self.path, "../../yaml/backdoor.tar.gz")

        command.append(tree_gui)
        command.extend(['-c', cpu])
        command.extend(['-S', shm])
        command.extend(['-N', str(slot)])
        command.extend(['-t', backdoor])
        command.extend(['-L', '512'])
        cmd = " ".join(command)
        print(cmd)

        return " ".join(command)


    def ui_filename(self):
        return "blen_loadSaveConfigFiles.ui"

    def ui_filepath(self):
        self.path = os.path.dirname(os.path.realpath(__file__))
        return os.path.join(self.path, self.ui_filename())

