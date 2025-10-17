# python packages, as added to the default pkgs python package
{
  system,
  pkgs,
  python,
  lib,
  ...
}@args:
with builtins;
let
  # source directory :
  srcDir = "../../python/";

# method to
  updatePkg = pl : p:  let 
    pkg = pkgs.callPackage p (args // {inherit srcDir;} // pl);
  in lib.recursiveUpdate pl
  { "${lib.getName pkg}" = pkg; };

  # add our python packages in the correct order :
  pythonPackages = foldl' updatePkg { } [
    ./slog.nix
    ./pycall.nix
    ./pysubfixer.nix
    ./pyinstaller.nix
    ./pyremdup.nix
  ];
in
# override python packages
python.override {
  packageOverrides = final: prev: pythonPackages;
}