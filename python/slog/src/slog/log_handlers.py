#!/usr/bin/env python

# python imports
from logging import (
    basicConfig as logConfig,
    getLogger,
    FileHandler,
    debug,
    INFO,
    DEBUG,
    Formatter
)
from sys import (
    stdout,
)
from pathlib import (
    Path,
)

# rich imports :
from rich.console import Console
from rich.logging import RichHandler


# simply get the name of the running app
__appname__ = Path(__file__).stem

def initialize() :
    """
        make logging display on stdout
        TODO : replace by class
    """
    # reset default logger :
    getLogger().handlers =[]
    getLogger().setLevel(0)
    # set stderr log :
    rhandler = RichHandler(  
        file= Console(file=stdout),
        markup=True)
    rhandler.setLevel(INFO)
    rhandler.setFormatter(Formatter(f'%(levelname)s : %(message)s ({__appname__}%(name)s)'))
    # log to file :
    filename = f"{__appname__}.log"
    Path(filename).unlink(missing_ok = True) # delete any existing log
    fhandler = FileHandler(filename, encoding="utf-8")
    fhandler.setLevel(DEBUG)
    fhandler.setFormatter(Formatter(f'%(levelname)s - %(asctime)s - %(name)s - %(message)s'))
    # set log config :
    logConfig( handlers=[fhandler, rhandler], force = True )
    debug("simple log configured")