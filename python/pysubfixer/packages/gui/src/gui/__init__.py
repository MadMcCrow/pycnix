#! /usr/env python
# gui/__init__.py : module for running as a GUI

# python
import sys

# Qt
from PySide6.QtWidgets import QApplication

# ours :
from .main_window import MainWindow


def main():
    """
    Launch the application
    """
    myApp = QApplication(sys.argv)
    try:
        widget = MainWindow()
        widget.show()
        retcode = myApp.exec()
    except Exception as E:
        print(f"Error : {repr(E)}")
        sys.exit(1)
    else:
        sys.exit(retcode)
