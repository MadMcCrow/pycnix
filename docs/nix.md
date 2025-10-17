# nix methods :

these methods are implemented in [the lib directory](../lib/).

##  [`mkCythonBin`](../nix/lib/mkCythonBin.nix)
let you compile complex scripts with cython : 
```nix
mkCythonBin {name = "test"; main =  "test" ; modules = [./test.py];};
```

## [`mkPipInstall`](../nix/lib/mkPipInstall.nix)
helps with having programs from pip
```nix
mkPipInstall {name = "test"; version = "0.1.0"; sha256 = ""; }
```