{ pkgs ? import <nixpkgs> { } }:
let
  test = pkgs.writeText "test.py" ''print ("Hello World")'';
  pynix = import ./python.nix { inherit pkgs; };
  cython-test = pynix.mkPyScript {
    name = "test-cython";
    main = "test";
    modules = [ test ];
  };
in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs.buildPackages; [
    pkgs.python310Full
    cython-test
  ];
}
