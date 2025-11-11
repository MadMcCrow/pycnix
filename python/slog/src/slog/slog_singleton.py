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
    module_name = str(getmodulename(s[2][1]))
    func_name = s[2][3]
    return module_name, func_name


def error(msg: str):
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.error(f"{msg.strip()} ({mod}::{name})")


def info(msg: str):
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.info(f"{msg.strip()} ({mod}::{name})")


def debug(msg: str):
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.debug(f"{msg.strip()} ({mod}::{name})")


def warning(msg: str):
    if not __initialized:
        initialize()
    mod, name = caller_id()
    logger = getLogger(mod)
    logger.warning(f"{msg.strip()} ({mod}::{name})")
