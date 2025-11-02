#! /usr/env python
# ffmpeg/ffmpeg.py : FFMpeg controls written in a pythonic way

# check if windows or linux/macOS :
from os import name as system

# enforce types 
from typing import (
    List,
    Optional
)

# ours
from .ffcmd import FFcmd
from .stdio import Parser

class FFmpeg(FFcmd) :
    """
        class to represent an instance of ffmpeg running in the background
    """

    class Parser(Parser) :
        """
        helper object to parse ffmpeg `--progress` object

        when ffmpeg displays some progress, 
        it looks like this :
            bitrate=1491.6kbits/s
            total_size=144965676
            out_time_us=777527528
            out_time_ms=777527528
            out_time=00:12:57.527528
            dup_frames=0
            drop_frames=0
            speed=1.56e+03x
            progress=continue
        """
        keywords =  [
                        'bitrate'
                        'total_size'
                        'out_time_us'
                        'dup_frames'
                        'drop_frames'
                        'speed'
                    ]
    
    cmd : str = "ffmpeg.exe" if system == 'nt' else "ffmpeg"
    parser = Parser() # use our parser instead
    defargs = ['--progress']