#!/usr/bin/env sh

curdir=$(pwd)
# update flake :
nix flake update

# update every uv lock :
for package in $curdir/python/*; do
    cd $package
    echo "syncing uv package : $package"
    nix-shell -p uv --run "uv sync"
    cd $curdir
done