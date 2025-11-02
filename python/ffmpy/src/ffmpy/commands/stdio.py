#! /usr/env python
# ffmpeg/stdio.py : parse ffmpeg commands output

from types import SimpleNamespace
from typing import (
    List,
    Optional,
)

from logging import (
    error
)

from datetime import timedelta

from re import (
    compile as regex,
    split,
)


_time_re = regex(r"(\d+):(\d+):(\d+\.\d+)")

def parse_time( timestr : str) -> Optional[float] :
    """
        static helper method to parse time as written by ffmpeg
    """
    try :
        m = _time_re.match(timestr)
        if m is not None :
            v = list(m.groups())
            time = timedelta(hours=int(v[0]),minutes=int(v[1]),seconds=float(v[2]))
            return time.total_seconds()
    except :
        pass

class Parser(object) :
    """
        base parsing object for ffcmds (ffprobe/ffmpeg)
    """

    keywords : list = []
    separators : list = [ ',' , ';' , ':' ]
    data : List[dict] = [{}]

    __idx : int = 0

    def update(self, line: str) :
        '''
            add line infos to data if matches keys.
            a new dict is made everytime we encounter an already defined key
        '''
        line = line.strip() # remove trailing whitespaces
        for l in line.splitlines():
            try :
                ws = split('|'.join(self.separators), l)
                for k in self.keywords :
                    if ws[0].strip().lower().startswith(k.strip().lower()) :
                        if k in self.data[self.__idx] :
                             self.data.append({})
                             self.__idx += 1
                        self.data[self.__idx][k] = ' '.join(ws[1:])
            except :
                error(f"failed to parse : {line}")