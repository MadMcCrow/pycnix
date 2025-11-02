#! /usr/env python
# gui/numericwidget.py : widget for selecting numbers

# python
from sys import maxsize

# QT
from PySide6.QtWidgets import QSpinBox, QSizePolicy
from PySide6.QtCore    import Signal, Slot


class NumericWidget(QSpinBox) :

    on_change = Signal(int)

    """
    A widget that allows selecting integers
    """
    def __init__(self, parent = None) :
        super(NumericWidget, self).__init__(parent)
        self.setValue(0)
        # max possible range
        self.setRange(-2147483648,2147483647)
        # create layout
        self.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Maximum)
        self.valueChanged.connect(self._post_change_value)

    @Slot(int)
    def _post_change_value(self, value) :
        # just pass value for now
        self.on_change.emit(value)
        

    