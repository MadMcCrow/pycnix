# mkPipInstall.nix
# mimic other systems `pip install {name}` by creating a derivation that contains
# the package
# usage :
#   mkPipInstall {name ,version, sha256}
pkgs:
{
  python ? pkgs.python311,
  pname,
  version,
  sha256,
  libraries ? [ ],
}:
with builtins;
let
  # allows writing just "pkgs" to use the correct one from python
  deps = map (x: if isString x then python.pkgs."${x}" else x) libraries;
in
# build extension from pypi
python.pkgs.buildPythonPackage {
  inherit version pname;
  src = python.pkgs.fetchPypi { inherit pname version sha256; };
  propagatedBuildInputs = deps;
}
