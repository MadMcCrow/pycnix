#! /usr/bin/python
# TODO : arg parse for folder and such
from sys import exit
from os import stat, listdir, path
from console import print

def _listfiles(directory) :
    extensions = ['.mp4', '.mkv']
    files = [f for f in listdir(directory) if (path.splitext(f)[1] in extensions and not f.startswith('.'))]
    files = list(map(lambda x: path.join(directory,x), files))
    files.sort(key = lambda x: stat(x).st_size, reverse=True) 
    return files

if __name__ == "__main__" :
    from compressor import Compressor 
    from argparse import ArgumentParser
    parser = ArgumentParser(
                        prog='video compressor script',
                        description='compress as much as possible every video in a folder')
    parser.add_argument('directory', default='./')
    parser.add_argument('-R', '--ratio', default='0.85')
    parser.add_argument('-T', '--target', default='../Converted')
    parser.add_argument('-Q', '--quality', default='60')
    parser.add_argument('-M', '--MinQuality', default='50')
    parser.add_argument('-E', '--error', default='0.1')
    args = parser.parse_args()

    try:
        indir = path.abspath(args.directory)
        outdir = path.abspath(path.join(indir, args.target))
        files =  _listfiles(indir)
        if len(files) == 0 :
            print(f'[error]Error:[/error] no videos in {indir}')
            exit(1)
        for video in files :
            Compressor(
                infile = video,
                dest = outdir,
                target  = float(args.ratio),
                quality = int(args.quality),
                limit = int(args.MinQuality),
                error   = float(args.error)
             )
    # handle Errors :
    except KeyboardInterrupt :
        print(f'[note]Error:[/note] stopped by user')
        exit(0)
    except Exception as E :
        print(f'[error]Undefined Error:[/error] {E}')
        exit(1)
    
