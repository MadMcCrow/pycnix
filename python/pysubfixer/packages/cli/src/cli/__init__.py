#! /usr/env python
# Command line interface

from argparse import ArgumentParser
from .probe import Probe
from sys import argv


def main():
    # spawn main object
    parser = ArgumentParser(
        description="command line tool to analyze modify video subtitles"
    )
    subparsers = parser.add_subparsers(description="available subcommands")
    # add probe command
    Probe().cmd(subparsers.add_parser("probe"))
    args = parser.parse_args(argv[1:])
    args.func(args)
