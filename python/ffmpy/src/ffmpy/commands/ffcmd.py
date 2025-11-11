#! /usr/env python
# ffmpeg/ffcmd : base class for all ffmpeg commands

# python imports
from abc import ABC

# pycall : launch command, async
from pycall import Pycall

# slog
from slog import debug, info, warning

from .args import Args

# ours
from .stdio import Parser


class FFcmd(ABC):
    """
    base class representing an ffmpeg command
    """

    # properties overriden by children
    cmd: str = ""
    parser: Parser | None = None
    defargs: list[str] = []

    # private properties
    __call: Pycall
    __args: Args

    def __init__(self):
        raise NotImplementedError(
            "Do not construct ffmpeg objects directly, use `run` instead"
        )

    @classmethod
    async def run(cls, *args, **kvargs):
        self = cls.__new__(cls)  # spawn
        self.__args = Args(*args, **kvargs)
        # run :
        print("calling pycall here !")
        self.__call = Pycall.call(
            self.cmd, self.defargs + self.__args.to_args(), [self._parseio]
        )
        await self.__call
        return self

    def __await__(self):
        return (yield from self.__call.__await__())

    def _parseio(self, instr: str, is_err: bool) -> float | None:
        """parse stdio streams (stdout, stderr) for ffmpeg output"""
        if self.parser is not None:
            self.parser.update(instr)  # parse line
        debug(f"{self.cmd} -> {'stderr' if is_err else 'stdout'}: {instr}")

    def __getattr__(self, name: str):
        """
        you can get parser attributes
        as if they were your own.
        """
        try:
            return getattr(self.parser, name)
        except Exception:
            warning(f"{self.cmd} : tried to access property {name} : not found")
            return None
