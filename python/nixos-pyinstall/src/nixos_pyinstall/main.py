#! /usr/env python3

from argparse import ArgumentParser
from sys import argv

class Main() : 
    def __init__(self) -> None:
        self.parser = ArgumentParser(description="tool to parse and install nixos configurations")
        subparsers = self.parser.add_subparsers(description='available subcommands')
        # add probe command
        self.parse_cmd(subparsers)
        args = self.parser.parse_args(argv[1:])
        # args.func(args)


    def parse_cmd(self, subparsers) : 
        parser = subparsers.add_parser('parse')
        parser.add_argument('nixconfig', help="config to parse")
        #parser.set_defaults(func=probe)

    def install_cmd(self, subparsers) : 
        parser = subparsers.add_parser('install')
        parser.add_argument('nixconfig', help="config to install")
        #parser.set_defaults(func=probe)
       