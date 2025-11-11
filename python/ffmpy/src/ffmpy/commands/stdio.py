#! /usr/env python
# ffmpeg/stdio.py : parse ffmpeg commands output

from datetime import timedelta
from re import (
    compile as regex,
)
from re import (
    split,
)

from slog import error

_time_re = regex(r"(\d+):(\d+):(\d+\.\d+)")


def parse_time(timestr: str) -> float | None:
    """
    static helper method to parse time as written by ffmpeg
    """
    try:
        m = _time_re.match(timestr)
        if m is not None:
            v = list(m.groups())
            time = timedelta(hours=int(v[0]), minutes=int(v[1]), seconds=float(v[2]))
            return time.total_seconds()
    except Exception:
        pass


class Parser(object):
    """
    base parsing object for ffcmds (ffprobe/ffmpeg)
    """

    keywords: list[str] = []
    separators: list[str] = [",", ";", ":", "="]
    data: list[dict[str, str]] = [{}]

    def __init__(self) -> None:
        self.__idx: int = 0

    def update(self, line: str):
        """
        add line infos to data if matches keys.
        a new dict is made everytime we encounter an already defined key
        """
        line = line.strip()  # remove trailing whitespaces
        for l in line.splitlines():
            try:
                # split requires separators to be in a string separated by |
                ws = [w.strip().lower() for w in split("|".join(self.separators), l)]
                for k in self.keywords:
                    k = k.strip().lower()
                    if ws[0].startswith(k):
                        if k in self.data[self.__idx]:
                            self.data.append({})
                            self.__idx += 1
                        self.data[self.__idx][k] = " ".join(ws[1:])
            except Exception:
                error(f"failed to parse : {line}")

    def list_attrs(self) -> list[str]:
        """
        get the list of values registered
        """
        retval = {}
        for d in self.data:
            retval.update(d)
        return list(retval.keys())

    def __getattr__(self, name: str):
        n = name.lower()
        for d in reversed(self.data):
            try:
                return d[n]
            except Exception:
                continue
        return None
