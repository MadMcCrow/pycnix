
import os
import difflib

def similarity(a,b) :
    s = difflib.SequenceMatcher(None, a, b)
    return s.ratio()

files = sorted([f for f in os.listdir('./') if not f.startswith('.')])


dups = []

for f in files :
    files_dup = files.copy()
    files_dup.remove(f)
    #files_dup.sort(lambda x: similarity(f))
    max_similary = 0.90
    for y in files_dup :
        r = similarity(f,y)
        if r > max_similary :
            format_str = 'probable dup = {0} == {1} ({2})'
            if not format_str.format( y, f ,max_similary) in dups :
                dup = format_str.format(f, y ,max_similary)
                print(dup)
                dups.append(dup)