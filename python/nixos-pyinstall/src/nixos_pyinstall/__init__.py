#! /usr/env python3
# import and run nixos-pyinstall
from .main import Main
from slog import Slog
from os import getcwd

def main():
    Slog()
    print(f"hello from nixos-pyinstall  : {getcwd()}")
    Main()

if __name__ == "__main__":
    main()