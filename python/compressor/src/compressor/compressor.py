#! /usr/bin/python
# convert a video until it is small enough
from ffmpeg import FFmpeg
from console import print
from os import path, stat, rename, remove, makedirs


class Compressor :
    def __init__(self, infile, dest, target = 0.85, quality = 60, limit = 50, error = 0.1) :
        print(infile)
        self._infile = infile
        self._video_codec = 'hevc_videotoolbox'
        self._audio_codec = 'copy'
        self._quality = quality
        self._target = target # at least achieve this compression
        self._limit = limit
        self._error_threshold  = error # compressed more than that is an error
        self._outdir = path.abspath(dest)
        self._run()

    def _outpath(self) : 
        return path.abspath(path.join(
        self._outdir, path.splitext(
        path.basename(self._infile))[0]
        .replace('1440', '1080')
        .replace('2160','1080')) + '.mp4')

    def _run(self) :
        print(f'[note]{self._infile}[/note] begin conversion to HEVC')
        print(self._outdir)
        makedirs(self._outdir, exist_ok=True)
        outpath = self._outpath()
        options = {
            '-c:v': self._video_codec,
            '-c:a': self._audio_codec,
            '-s' : '1920x1080',
            '-q:v' : self._quality,
            '-tag:v': 'hvc1',
            }
        cmd = FFmpeg(self._infile, outpath, options)
        insize = stat(self._infile).st_size
        outsize = stat(outpath).st_size
        ratio = (outsize / insize)
        if ratio < self._error_threshold : 
            print(f'[warning]{self._infile}[/warning] compressed to much ({ratio}), must be a mistake ') 
            self._quality = self._quality + 5
            print(f'[info]{self._infile}[/info]trying with higher quality ({self._quality})')
            remove(outpath)
            # restart :
            self._run()
        elif ratio > self._target  : 
            print(f'[warning]{self._infile}[/warning] not compressed enough ({ratio})')
            remove(outpath)
            if self._quality > self._limit :
                self._quality = self._quality - 5
                print(f'[info]{self._infile}[/info]trying with lower quality ({self._quality})')
                # restart :
                self._run()
            else :
                print(f'[info]{self._infile}[/info]keeping original')
                rename(self._infile, outpath)
        else :
            print(f'[success]{self._infile}[/success]compression successful{"{:.2f}".format(outsize/insize)} with quality = {self._quality}')
            remove(self._infile)