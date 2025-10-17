# pycall.nix
# provide pycall as a python package
{
  pkgs,
  python,
  srcDir,
  ...
}:
with python.pkgs;
buildPythonPackage rec {
  pname = "pycall";
  version = "0.1.0"; # TODO retrieve from pyproject file !
  src = srcDir + pname;
  pyproject = true;
  buildInputs = [
    poetry-core
    rich
    uv
  ];
  propagatedBuildInputs = buildInputs;
  meta = with pkgs.lib; {
    licences = [ licences.mit ];
    platforms = platforms.x86_64 ++ platforms.aarch;
  };
}
