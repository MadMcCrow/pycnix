#! /usr/env python
# cli/subs : a wrapper around calling ffmpeg, ffprobe or ffplay with python

# ffmpy
from argparse import ArgumentParser, Namespace

# ours :
from asyncio import run
from pathlib import Path

from ffmpy import Media


class Probe:
    def __init__(self):
        pass

    def cmd(self, subparser: ArgumentParser):
        _ = subparser.add_argument("file", help="media file to probe with ffprobe")
        subparser.set_defaults(func=probe)


async def _async_probe(media: Media):
    await media.probe()
    print(media.duration)


def probe(args: Namespace):
    path = Path(str(args.file))
    media = Media(path)
    run(_async_probe(media))
