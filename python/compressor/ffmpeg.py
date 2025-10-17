#! /usr/bin/python
#   FFMPEG wrapper
#   simplify interacting with the ffmpeg cli
#   TODO get progress
#   TODO optimize imports

from time import sleep
from console import print

class FFmpeg :

    # get ffmpeg command (do not call)
    @classmethod
    def FF(cls) :
        try : 
            return cls._FF
        except AttributeError :
            from sh import ffmpeg
            cls._FF = ffmpeg
            return cls._FF

    # make the call directly, act as a function
    def __init__(self, source : str, output: str, options = {} ) :
        # Simply convert a video from source to target with options
        self.options = options
        self.source = source
        self.output = output
        # run :
        self._call()

    def _parseoptions(self) :
        ll = ([[x, y] for (x,y) in self.options.items()])
        return [x for xs in ll for x in xs]

    def _call(self) :
        from sh import ErrorReturnCode
        display = f"converting : '{self.source}' to '{self.output}'"
        options = self.options,
        try :
            p = FFmpeg.FF()(
            '-i', self.source,
            *(self._parseoptions()),
            self.output,
            _new_session=False, 
            #_no_err = True, 
            _bg=True, 
            _bg_exc = False)
            # wait end of execution
            i = 0
            while p.is_alive() :
                    i+=1
                    print('\r' f"{display}{[x*'.' + (3-x)*' ' for x in range(1,4)][(i % 3)-1]}", end = '\r')
                    sleep(1)
            p.wait()
        except ErrorReturnCode :
            print('\n' f'[error]ERROR: ffmpeg exited with error code {p.exit_code}[/error]')
            print(p.ran)
            print(p.stderr)
        else :
            print(f"{display}...[success]DONE[/success]")