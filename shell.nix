# Shell.nix :
# demo and test functions from our library
{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) lib;
  # shell.nix
  python = pkgs.python311;

  # our functions
  mkCythonBin = import ./lib/mkCythonBin.nix pkgs;
  mkPipInstall = import ./lib/mkPipInstall.nix pkgs;
  mkCxFreezeBin = import ./lib/mkCxFreezeBin.nix pkgs;

  # Demo :
  # print infos about a pip library and a system library
  testScript = pkgs.writeText "test.py" ''
    print(f"name is : {__name__}")
    import age.file as age
    print(f"age : {age}")
    import Crypto
    print(f"Crypto : {Crypto}")
  '';

  # library from pip
  pyage = mkPipInstall {
    inherit python;
    pname = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = [ "pynacl" "requests" "cryptography" "click" "bcrypt" ];
  };

  pycrypto = mkPipInstall {
    pname = "pycryptodome";
    version = "3.19.0";
    sha256 = "sha256-vDXUYyIs202+vTXgeEFVyB4WG5KE5Wfn6TPXIuUzMx4=";
    libraries = [ ];
  };

  # build to a binary
  cython-test = mkCythonBin {
    inherit python;
    unpackPhase = ''
      for srcFile in $src; do
      srcList+=$(stripHash $srcFile)
      cp $srcFile $(stripHash $srcFile)
      done
    '';
    pname = "cython-test";
    version = "0.1";
    src = testScript;
    libraries = [ pyage "pycryptodome" ];
  };

  cxfreeze-test = mkCxFreezeBin {
    pname = "cxfreeze-test";
    version = "0.01";
    src = testScript;
    main = "${testScript}";
    includes = [ "Crypto" "age" ];
    nativeBuildInputs = [ pycrypto pyage ];
  };

  pyinstaller-test = mkCxFreezeBin {
    pname = "cxfreeze-test";
    version = "0.01";
    src = testScript;
    main = "${testScript}";
    unpackPhase = ''
      if [ -d $src ]; then
        cp -r $src/* ./
      else 
        cp $src ./$(stripHash $src)
      fi
      find . -type f -exec touch -a -m {} +
    '';
    includes = [ "Crypto" "age" ];
    nativeBuildInputs = [ pycrypto pyage ];
  };

  # make a shell with it
in pkgs.mkShell { buildInputs = [  cython-test  ]; }
