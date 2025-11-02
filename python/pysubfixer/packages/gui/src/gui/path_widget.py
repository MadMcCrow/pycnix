#! /usr/env python
# gui/filepathwidget.py : widget for picking input files 

# python
import os

# QT
from PySide6.QtWidgets import (
    QWidget,
    QHBoxLayout,
    QPushButton,
    QLineEdit,
    QFileDialog,
    QSizePolicy)
from PySide6.QtCore import Qt, Signal


class FilePathWidget(QWidget) :
    """
        A container that helps picking files
    """

    # custom signal
    on_change = Signal(str)

    def __init__(self, parent = None) :
        super(FilePathWidget, self).__init__(parent)
        # subwidgets
        self.textbox = QLineEdit()
        self.selectbtn = QPushButton("pick")
        self.selectbtn.clicked.connect(self.on_button_clicked)
        # layout
        horizontalLayout = QHBoxLayout()
        horizontalLayout.addWidget(self.textbox)
        horizontalLayout.addWidget(self.selectbtn)
        horizontalLayout.setAlignment(Qt.AlignVCenter | Qt.AlignHCenter)
        self.setLayout(horizontalLayout)
        # size policy
        self.textbox.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.Maximum)
        self.setSizePolicy(QSizePolicy.MinimumExpanding, QSizePolicy.Maximum)

    def on_button_clicked(self, event):
        # TODO : allow selecting correct type : 
        # https://doc.qt.io/qtforpython-6/PySide6/QtWidgets/QFileDialog.html#PySide6.QtWidgets.QFileDialog.getOpenFileName
        filepath, _filter = QFileDialog.getOpenFileName(self, 'Select Path')
        self.textbox.setText(filepath)
        self.on_change.emit(self.path())

    def path(self) -> str :
        # correct the type of the path
        return os.path.abspath(self.textbox.text())

    
        
