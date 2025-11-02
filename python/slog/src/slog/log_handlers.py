#!/usr/bin/env python

# python imports
from logging import (
    basicConfig as logConfig,
    getLogger,
    StreamHandler,
    FileHandler,
    INFO,
    DEBUG,
    Formatter,
)
from sys import (
    stdout,
)
from pathlib import (
    Path,
)
from typing import Optional

# rich imports :
try:
    from rich.console import Console
    from rich.logging import RichHandler

    _rich_enabled = True
except ModuleNotFoundError:
    _rich_enabled = False


# simply get the name of the running app
__appname__ = Path(__file__).stem


def consoleHandler() -> StreamHandler:
    """
    create a stdout compatible handler
    """
    if _rich_enabled:
        return RichHandler(file=Console(file=stdout), markup=True)
    else:
        return StreamHandler(stream=stdout)


def logfileHandler(path: Optional[str] = None) -> StreamHandler:
    """
    create a logHandler to write to a file at a correct directory
    """
    if path is not None:
        pdir = Path(path)
        pdir.mkdir(parents=True, exist_ok=True)
        logfile = pdir / f"{__appname__}.log"
    else:
        logfile = Path(f"{__appname__}.log")
    # delete any existing log and return
    logfile.unlink(missing_ok=True)
    return FileHandler(str(logfile), encoding="utf-8")


def initialize(logpath: Optional[str] = None):
    """
    make logging display on stdout
    TODO : replace by class
    """
    # reset default logger :
    getLogger().handlers = []
    getLogger().setLevel(0)
    # set stderr log :
    chandler = consoleHandler()
    chandler.setLevel(INFO)
    chandler.setFormatter(
        Formatter(f"%(levelname)s : %(message)s ({__appname__}%(name)s)")
    )
    # log to file :
    fhandler = logfileHandler(logpath)
    fhandler.setLevel(DEBUG)
    fhandler.setFormatter(
        Formatter(f"%(levelname)s - %(asctime)s - %(name)s - %(message)s")
    )
    # set log config :
    logConfig(handlers=[fhandler, chandler], force=True)
