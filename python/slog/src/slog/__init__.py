#!/usr/bin/env python

# import our initialization method
from .log_handlers import initialize

# import default logging methods
from logging import (error, info, critical, warning)

class Slog():
    def __init__(self) :
        initialize()
<<<<<<< HEAD
        info("Slog initialized !")
    
=======
        info("Slog initialized !")
>>>>>>> acffb90 (started working on nixos-pyinstaller)
