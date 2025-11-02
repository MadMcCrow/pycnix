#! /usr/env python
# gui/form.py : provide a form layout

from PySide6.QtWidgets import QWidget, QFormLayout
from PySide6.QtCore import Qt

class FormWidget(QWidget) :
    """
        simple widget containing a form layout
    """
    def __init__(self, parent = None) : 
        super(FormWidget, self).__init__(parent)
        self.formlayout = QFormLayout(self)
        self.formlayout.setFormAlignment( Qt.AlignRight | Qt.AlignVCenter)
        self.formlayout.setLabelAlignment(Qt.AlignLeft | Qt.AlignTop)
        self.formlayout.setFieldGrowthPolicy(QFormLayout.AllNonFixedFieldsGrow)
        
    def add_widget(self, label, widget) :
        widget.setParent(self)
        self.formlayout.addRow(label, widget)
        return widget


