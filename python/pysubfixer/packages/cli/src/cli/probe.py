#! /usr/env python
# cli/subs : a wrapper around calling ffmpeg, ffprobe or ffplay with python

# ffmpy
from ffmpy import Media

# ours :
from asyncio import run

import sys

from pathlib import Path

async def _async_probe(media : Media) :
    await media.probe()
    print(media.duration)

def probe(args) :
    path = Path(args.file)
    media = Media(path)
    run(_async_probe(media))