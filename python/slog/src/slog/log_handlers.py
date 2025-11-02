#!/usr/bin/env python

# python imports
from logging import (
    basicConfig as logConfig,
    getLogger,
    Handler,
    StreamHandler,
    FileHandler,
    INFO,
    DEBUG,
    Formatter,
)
from sys import stdout, argv
from pathlib import (
    Path,
)

# rich imports :
from rich.console import Console
from rich.logging import RichHandler

# TODO : make this a config variable
_rich_enabled = True


def formatter(
    *, level: bool = True, time: bool = True, name: bool = True, caller: bool = True
) -> Formatter:
    """
    build a log formatter
    /note : str * bool = str if bool else ''
    """
    fstrs = [
        "%(levelname)s" * level,
        "%(asctime)s" * time,
        "%(name)s" * name,
        "%(message)s",
        "(%(filename)s::%(funcName)s)" * caller,
    ]
    sep = " - "
    return Formatter(sep.join(fstrs))


def consoleHandler() -> Handler:
    """
    create a stdout compatible handler
    """
    if _rich_enabled:
        # see https://rich.readthedocs.io/en/latest/reference/logging.html
        # for options
        rh = RichHandler(console=Console(file=stdout), markup=True)
        rh.setFormatter(formatter(level=False))
    else:
        rh = StreamHandler(stream=stdout)
        rh.setFormatter(formatter())
    return rh


def logfileHandler(path: str | None = None) -> Handler:
    """
    create a logHandler to write to a file at a correct directory
    """
    appname = argv[0]
    if path is not None:
        pdir = Path(path)
        pdir.mkdir(parents=True, exist_ok=True)
        logfile = pdir / f"{appname}.log"
    else:
        logfile = Path(f"{appname}.log")
    # delete any existing log and return
    logfile.unlink(missing_ok=True)
    fh = FileHandler(str(logfile), encoding="utf-8")
    fh.setFormatter(formatter())
    return fh


def initialize(logpath: str | None = None):
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
    # log to file :
    fhandler = logfileHandler(logpath)
    fhandler.setLevel(DEBUG)
    # set log config :
    logConfig(handlers=[fhandler, chandler], force=True)
