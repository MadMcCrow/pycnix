# Shell.nix : 
# demo and test functions from our library
{ pkgs ? import <nixpkgs> { } }:
let
  # shell.nix
  python = pkgs.python310;

  # our functions
  mkCythonBin = import ./mkCythonBin.nix pkgs;
  mkPipInstall = import ./mkPipInstall.nix pkgs;


  # Demo :
  # print infos about a pip library and a system library
  test-cython = pkgs.writeText "test.py" ''
  print(f"name is : {__name__}")
  import age.file as age
  print(f"age : {age}")
  import Crypto
  print(f"Crypto : {Crypto}")
  '';

  # library from pip
  pyage = mkPipInstall {
    inherit python;
    name = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = ["pynacl" "requests" "cryptography" "click" "bcrypt"];
  };

  # build to a binary
  cython-test = mkCythonBin {
    inherit python;
    name = "cython-test";
    main = "test";
    modules = [  test-cython ];
    libraries = [ pyage "pycryptodome" ];
  };

# make a shell with it
in pkgs.mkShell {
  buildInputs = [
    cython-test
  ];
}
