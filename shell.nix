{ pkgs ? import <nixpkgs> { } }:
let


  python = pkgs.python310;

  mkCythonBin = import ./mkCythonBin.nix pkgs   python;
  mkPipInstall = import ./mkPipInstall.nix pkgs python;



  # Demo : download a pip command and print all about it :
  test = pkgs.writeText "test.py" ''
  from age import cli
  print( cli.decrypt )
  '';

  pyage = mkPipInstall {
    name = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = ["pynacl" "requests" "cryptography" "click" "bcrypt"];
  };

  cython-test = mkCythonBin {
    name = "test-cython";
    main = "test";
    modules = [ test ];
    libraries = [ pyage ];
  
  };
in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  buildInputs = [
    pkgs.python310Full
    cython-test
    pyage
  ];
}
