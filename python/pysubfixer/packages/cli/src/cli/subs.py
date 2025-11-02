#! /usr/env python
# cli/subs : a wrapper around calling ffmpeg, ffprobe or ffplay with python

# python
import os
# ours 
from ffmpeg import FFmpeg
from ffmpeg import MediaFile


async def remove_subs(video : MediaFile) :
        output = "{}.sn{}".format(*os.path.splitext(video)) 
        await FFmpeg.run( input=video, output=output, options = "-c:v copy -c:a copy -sn" )

async def delay_subs(subs, delay :int = 0) :
        output = "{0}.{2}{1}".format(*(os.path.splitext(subs) + (delay,)))
        await FFmpeg.run( input=subs, output=output, options=f"-itsoffset {delay}" )