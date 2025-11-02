# nix/default.nix
{
  lib,
  system,
  nixpkgs,
  ...
}@args:
let
  pkgs = nixpkgs.legacyPackages.${system};
  mkPackage = name: import ./lib/mkpackage.nix (args // { inherit pkgs; }) name;
in
builtins.listToAttrs (
  map
    (x: {
      name = x;
      value = mkPackage x;
    })
    [
      "pycall"
      "ffmpy"
      "hello-world"
      "pysubfixer"
      "slog"
    ]
)
