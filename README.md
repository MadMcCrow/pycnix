# pycnix

pycnix (picnics) is a simple flake to help package and run python scripts

##  `mkCythonBin`
let you compile complex scripts with cython : 
```nix
mkCythonBin {name = "test"; main =  "test" ; modules = [./test.py];};
```

## `mkPipInstall`
helps with having programs from pip
```nix
mkPipInstall {name = "test"; version = "0.1.0"; sha256 = ""; }
```
