#! /usr/env python
# gui/mainwidget.py : main application window

# python
from typing import Callable
import os

# PySide6
from PySide6.QtWidgets import (
    QWidget,
    QMainWindow,
    QPushButton,
    QVBoxLayout
    )
from PySide6.QtCore import Qt, Slot, Signal

# ours
from gui.ffmpeg_button   import RunButton
from gui.numeric_widget  import NumericWidget
from gui.form_widget     import FormWidget
from gui.path_widget     import FilePathWidget

class MainWindow(QMainWindow) :
    """
        Main Application window
    """

    def __init__(self, name="pysubfixer-gui") :
        super(MainWindow, self).__init__()
        self.resize(500, 250)
        self.setWindowTitle(name)
        # a nice simple layout
        mainwidget = QWidget(self)
        mainwidget.setLayout(QVBoxLayout())
        mainwidget.layout().setAlignment(Qt.AlignVCenter)
        formwidget = FormWidget(mainwidget)
        # our form widgets
        formwidget.add_widget(self.tr("&video :"), FilePathWidget()).on_change.connect(self.on_video_set)
        formwidget.add_widget(self.tr("&subtitles :"), FilePathWidget()).on_change.connect(self.on_subs_set)
        formwidget.add_widget(self.tr("&delay (seconds) :"), NumericWidget()).on_change.connect(self.on_delay_set)
        formwidget.add_widget(self.tr("&output :"), FilePathWidget()).on_change.connect(self.on_output_set)
        # update layout :
        mainwidget.layout().addWidget(formwidget)
        # execute button
        self._run_button = RunButton(self)
        mainwidget.layout().addWidget(self._run_button)
        # simple unique widget :
        self.setCentralWidget(mainwidget)


    @Slot(str)
    def on_video_set(self, path) :
        self._run_button.video = path
        
    @Slot(str)
    def on_subs_set(self, path) :
        self._run_button.subs = path

    @Slot(int)
    def on_delay_set(self, secs) :
        self._run_button.delay = secs

    @Slot(str)
    def on_output_set(self, path) :
        self._run_button.output = path





