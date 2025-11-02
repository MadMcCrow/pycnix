#! /usr/env python
# cli/main : commandline function 


# python import :
from sys import argv

from argparse import ArgumentParser
# our commands 

from .probe import probe

class Main() :

    def __init__(self) -> None:
        self.parser = ArgumentParser(description="command line tool to analyze modify video subtitles")
        subparsers = self.parser.add_subparsers(description='available subcommands')
        # add probe command
        self.probe_cmd(subparsers)
        args = self.parser.parse_args(argv[1:])
        args.func(args)


    def probe_cmd(self, subparsers) : 
        parser = subparsers.add_parser('probe')
        parser.add_argument('file', help="media file to probe with ffprobe")
        parser.set_defaults(func=probe)
       