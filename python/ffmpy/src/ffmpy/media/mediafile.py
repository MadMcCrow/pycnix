#! /usr/env python
# ffmpeg/media :    class to describe a media file
#                   

# python libs
from pathlib import Path
from typing import (
    Optional,
    Callable,
    TypeAlias
)
from logging import (
    error
)

# ours :
from ..commands import FFprobe

class Media(object) :
    """
        class to represent a media path
        this is a wrapper, but it also helps with querying infos
    """

    # type alias to fixup a path that errors out 
    ErrorHandler : TypeAlias = Callable[["Media", Exception], None]

    def __init__(self, path : str | Path) -> None:
        # initialize path property
        if isinstance(path, Path) :
            self._path = path.expanduser()
        else :
            self._path = Path(path).expanduser()
        # reset probe object
        self.__probe = None



    def check(self, should_exist : bool, handler : Optional[ErrorHandler] ) :
        """
            checks for errors, and allow fixing up
        """
        try : 
            self._check_path(should_exist)
        except Exception as E :
            if handler is not None :
                handler(self, E)
            else :
                raise E


    def _check_path( self, should_exist : bool ) -> None :
        """
            raise the correct error for 
            keyword arguments :
            -- file : the str path of the file or 
        """
        if self._path.is_dir() :
            raise IsADirectoryError(f"{self._path} is a directory !")
        if should_exist is not None :
            if self._path.exists() != should_exist:
                    if should_exist :
                        raise FileNotFoundError(self._path)
                    else :
                        raise FileExistsError(self._path)

    @property
    def extension(self) -> str : 
        "return the file extension"
        return self._path.suffix

    def path_str(self) -> str :
        """ return a well formed string """
        p = self._path.expanduser().resolve(True)
        return str(p)

    async def probe(self) :
        """
            call probe on this media
        """
        if not self._path.exists() or not self._path.is_file() :
            raise FileNotFoundError(f"tried to probe non-existing file {self}")
        if not isinstance(self.__probe, FFprobe) : 
            self.__probe = await FFprobe.run(self.path_str())

    
    def __getattr__(self, name : str) :
        """
            use the result of a previous probe call
        """
        try :
             return getattr(self.__probe, name)
        except Exception as E :
            error(
                f"""{self} : tried to access property {name} : not found
                {E} (have you tried to call `probe` first ?)
                """)
            return None