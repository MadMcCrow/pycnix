# python packages, as added to the default pkgs python package
{
  system,
  pkgs,
  python,
  lib,
  self,
  ...
}@args:
with builtins;
let
  # source directory :
  srcDir = self + "/python/";

  mkPackage =
    name:
    let
      project = pyproject-nix.lib.project.loadPyproject {
        projectRoot = srcDir + "pycall";
      };
    in
    buildPythonPackage (project.renderers.buildPythonPackage { inherit python; });

  # method to merge packages:
  # pkgs.callPackage p (args // {inherit srcDir;} // pl);
  updatePkg =
    pl: p:
    let
      pkg = mkPackage p;
    in
    lib.recursiveUpdate pl { "${lib.getName pkg}" = pkg; };

  # add our python packages in the correct order :
  pythonPackages = foldl' updatePkg { } [
    "slog"
    "pycall"
    "pysubfixer"
    # ./pyremdup.nix
  ];
in
# override python packages
python.override {
  packageOverrides =
    final: prev:
    (
      # our uv packages :
      pythonPackages
      // {
        # add pyinstaller :
        pyinstaller = pkgs.callPackage ./pyinstaller.nix { };
      }
    );
}
