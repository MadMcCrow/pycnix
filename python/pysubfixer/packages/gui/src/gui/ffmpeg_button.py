#! /usr/env python
# gui/filepathwidget.py : widget for picking input files 

# python
import shlex
import asyncio

# QT
from PySide6.QtWidgets import QStackedWidget, QPushButton, QProgressBar


class RunButton(QStackedWidget) :
    """
        nice button to run a command
    """

    video  : str = ""
    subs   : str = ""
    delay  : int = 0
    output : str = ""
 

    def update(self) :
        # update subwidgets:
        self._button.setText(self.get_label())
        self._progressbar.setRange(0, 0 if self.__clicked else 1)
        # set correct visibility :
        self.setCurrentWidget(self._progressbar if self.__clicked else self._button)

    def on_finished(self):
        # Stop the pulsation
        self._progressbar.setRange(0,1)
        self.update()

    def get_label(self) -> str :# our
        if self.__clicked :
            return self.tr("&FFMpeg Running, please wait")
        else :
            return self.tr("Run FFMpeg")

    def get_tooltip(self) -> str :
        if self.__clicked :
            return self.tr("&Running the correct ffmpeg sequence, don't worry")
        else :
            return self.tr("&click to embed ") + self.subs + self.tr("& into") + self.video

    def __init__(self, parent) : 
        super().__init__(parent)
        self.__clicked = False
        # add subwidgets :
        self._button = QPushButton()
        self._progressbar = QProgressBar()
        self.addWidget(self._button)
        self.addWidget(self._progressbar)
        # update appearance :
        self.update()
        # on clicked :
        self._button.clicked.connect(self._on_exec)

    def _on_exec(self) :
        loop = asyncio.get_event_loop()
        self.__clicked = True
        self.update()
        #self.task = loop.create_task(fix_subs(
        #    subs  = self.subs,
        #    video = self.video,
        #    delay = self.delay,
        #    output = self.output,
        #    on_finished=self.on_finished))
        