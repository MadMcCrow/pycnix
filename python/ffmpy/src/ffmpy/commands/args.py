#! /usr/env python
# ffmpeg/args.py : FFmpeg command line arguments

from typing import (
    List,
    Optional,
    NamedTuple,
    TypeAlias
)

from pathlib import Path 

class FilePattern(NamedTuple) :
    path : str
    options : str

    def to_arg(self, prefix : Optional[str] = None) -> str :
        """
            fixes path to be correct for commandline 
        """
        if self.path == '' :
            return '' # filter out invalid
        fixed_path = Path(self.path).expanduser().resolve(True)
        return f"{self.options} {prefix} '{str(fixed_path)}'"

def _conditional_pattern(arg : Optional[FilePattern|str]) -> FilePattern :
    """ make sure to return a FilePattern """
    if arg is None :
        return FilePattern("", "") 
    if isinstance(arg, str) :
        return FilePattern(arg, "")
    return arg 

FileType : TypeAlias = FilePattern|str

class Args(object) :
    """
    ffmpeg [global_options] {[input_file_options] -i input_url} ... {[output_file_options] output_url} ... 
    """
    
    
    def __init__(self, inputs : List[FileType]|FileType, output : Optional[FileType] = None, ) :     
        # parse inputs as files or list of files    
        if isinstance(inputs, list) : 
            self.inputs = [_conditional_pattern(f) for f in inputs]
        elif isinstance(inputs, FileType) :
            self.inputs = [_conditional_pattern(inputs)]
        # parse output
        self.output = _conditional_pattern(output)

    def to_args(self) -> List[str] :
        """
            produce a list of strings to be ingested by the command line 
        """
        result = [i.to_arg('-i') for i in self.inputs]
        result.append(self.output.to_arg())
        return ' '.join(list(filter(('').__ne__, result))).split() # remove empty elements