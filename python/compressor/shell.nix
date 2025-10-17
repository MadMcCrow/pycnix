{
  pkgs ? import <nixpkgs> { },
}:
with pkgs;
mkShell {
  inputsFrom = [ (callPackage ./default.nix { }) ];
}
