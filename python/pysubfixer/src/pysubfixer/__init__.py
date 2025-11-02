#! /usr/env python
# run pysubfixer

def pysubfixercli() :
    from cli import pysubfixer_cli
    pysubfixer_cli()

def pysubfixergui() :
    from gui import qt_app
    qt_app()
    
# prefer GUI
if __name__ == "__main__":
    pysubfixergui()
