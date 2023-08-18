{ pkgs ? import <nixpkgs> { } }:
let


  python = pkgs.python310;

  mkCythonBin = import ./mkCythonBin.nix pkgs   python;
  mkPipInstall = import ./mkPipInstall.nix pkgs python;



  # Demo : download a pip command and print all about it :
  test-cython = pkgs.writeText "test.py" ''
  print(f"name is : {__name__}")
  import age.file as age
  print(f"age : {age}")
  '';

  pyage = mkPipInstall {
    name = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = ["pynacl" "requests" "cryptography" "click" "bcrypt"];
  };

  cython-test = mkCythonBin {
    name = "cython-test";
    main = "test";
    modules = [  test-cython ];
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
