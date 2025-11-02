#!/usr/bin/env python

# import our initialization method
from .log_handlers import initialize

# import default logging methods
from logging import (error, info, critical, warning, getLogger)

# TODO : make slog a singleton
# TODO : create a new logger everytime it is called
# TODO : 

class Slog():
<<<<<<< HEAD
    def __init__(self) :
        initialize()
<<<<<<< HEAD
        info("Slog initialized !")
    
=======
        info("Slog initialized !")
>>>>>>> acffb90 (started working on nixos-pyinstaller)
=======
    def __init__(self, logdir = None) :
        print ("hello from slog !")
        initialize(logdir)
        slogger = getLogger('slog')
        slogger.warning("Slog initialized !")
>>>>>>> 48cfb6d (nixos-pyinstaller and logging WIP)
