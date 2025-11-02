#! /usr/env python
# ffmpeg/ffcmd : base class for all ffmpeg commands

# python imports
from abc import ABC
from typing import (
    List,
    Optional,
)
from logging import (
    warning,
    info
)

# pycall : launch command, async
from pycall import Pycall

# ours
from .stdio import Parser
from .args import Args

class FFcmd(ABC) :
    """
        base class representing an ffmpeg command
    """

    # properties overriden by children
    cmd  : str = ""
    parser : Optional[Parser] = None
    defargs : List[str] = []

    # private properties
    __call  : Pycall
    __args  : Args

    def __init__(self) :
        raise NotImplementedError(
            "Do not construct ffmpeg objects directly, use `run` instead")


    @classmethod
    async def run(cls, *args, **kvargs) :
        self = cls.__new__(cls) # spawn
        self.__args = Args(*args, **kvargs)
        # run :
        final_args = self.defargs + self.__args.to_args()
        print(f"{final_args}")
        self.__call = Pycall.call("ls", self.defargs + self.__args.to_args(), [self._parseio])
        await self.__call
        return self


    def __await__(self) :
        return (yield from  self.__call.__await__())


    def _parseio(self, instr : str, is_err : bool) -> Optional[float] :
        """ parse stdio streams (stdout, stderr) for ffmpeg output """
        if self.parser is not None :
            self.parser.update(instr) # parse line
        if is_err :
            warning(f"{self.cmd} : {instr}")
        else :
            info(f"{self.cmd} : {instr}")


    def __getattr__(self, name : str) :
        """
            you can get parser attributes
            as if they were your own. 
        """
        try : 
            getattr(self.parser, name)
        finally :
            warning(f"{self.cmd} : tried to access property {name} : not found")
            return None