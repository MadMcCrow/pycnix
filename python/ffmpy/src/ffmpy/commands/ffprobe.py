#! /usr/env python
# ffmpeg/ffprobe.py :run ffprobe more snakily

# check if windows or linux/macOS :
from os import name as system

# ours
from .ffcmd import FFcmd
from .stdio import Parser

class FFprobe(FFcmd) :
    """
        class to represent an instance of ffprobe running in the background
    """

    class Parser(Parser) :
        """
        helper object to parse ffprobe infos
        when ffprobe displays informations, 
        it looks like this :
             Stream #0:0(eng): Video: hevc (Main 10), yuv420p10le(tv, bt709), 1920x1080 [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn (default) (forced)
                Metadata:
                    ENCODER         : Lavc58.134.100 libx265
                    BPS-eng         : 3750684
                    DURATION-eng    : 00:41:58.478000000
                    NUMBER_OF_FRAMES-eng: 60383
                    NUMBER_OF_BYTES-eng: 1180751924
                    _STATISTICS_WRITING_APP-eng: mkvmerge v41.0.0 ('Smarra') 64-bit
                    _STATISTICS_WRITING_DATE_UTC-eng: 2021-11-02 20:09:24
                    _STATISTICS_TAGS-eng: BPS DURATION NUMBER_OF_FRAMES NUMBER_OF_BYTES
        """
        keywords =  [
                       "Stream", 
                       "DURATION"
                    ]
    
    cmd : str = "ffprobe.exe" if system == 'nt' else "ffprobe"