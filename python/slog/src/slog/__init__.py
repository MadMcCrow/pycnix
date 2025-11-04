#!/usr/bin/env python

# import the methods to expose to other systems !
from .slog_singleton import (
    initialize,  # do this first in your application
    error,
    info,
    debug,
    warning,
)
