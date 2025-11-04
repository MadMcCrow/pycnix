#! /usr/bin/env python3
# slog module acting as a singleton

# import our initialization method
from .log_handlers import logfileHandler, consoleHandler

# import default logging methods
from logging import (
    INFO,
    DEBUG,
    basicConfig,
    getLogger,
)

from inspect import stack, getmodulename


if "__initialized" not in dir():
    __initialized = False


def initialize(logpath: str | None = None):
    """
    Initialize slog system
    """
    global __initialized
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
    basicConfig(handlers=[fhandler, chandler], force=True)
    slogger = getLogger("slog")
    slogger.warning("Slog initialized !")
    __initialized = True


def caller_id() -> tuple[str, str]:
    """Returns an informative prefix for log output messages"""
    s = stack()
    module_name = str(getmodulename(s[1][1]))
    func_name = s[1][3]
    return module_name, func_name


def error(msg: str):
    if not __initialized:
        initialize()
    logger = getLogger(caller_id()[0])
    logger.error(msg)


def info(msg: str):
    if not __initialized:
        initialize()
    logger = getLogger(caller_id()[0])
    logger.info(msg)


def debug(msg: str):
    if not __initialized:
        initialize()
    logger = getLogger(caller_id()[0])
    logger.debug(msg)


def warning(msg: str):
    if not __initialized:
        initialize()
    logger = getLogger(caller_id()[0])
    logger.warning(msg)
