#!/usr/bin/env python

# python imports
from logging import (
    basicConfig as logConfig,
    getLogger,
    StreamHandler,
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
    console = StreamHandler(stdout)
    console.setLevel(INFO)
    console.setFormatter(Formatter(f'%(levelname)s : %(message)s ({__appname__}%(name)s)'))
    # log to file :
    filename = f"{__appname__}.log"
    Path(filename).unlink(missing_ok = True) # delete any existing log
    fhandler = FileHandler(filename, encoding="utf-8")
    fhandler.setLevel(DEBUG)
    fhandler.setFormatter(Formatter(f'%(levelname)s - %(asctime)s - %(name)s - %(message)s'))
    # set log config :
    logConfig( handlers=[file, console], force = True )
    debug("simple log configured")