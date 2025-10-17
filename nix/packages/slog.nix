# pycall.nix
# provide pycall as a python package
{
  pkgs,
  lib,
  python,
  srcDir,
  ...
}:
with python.pkgs;
buildPythonPackage rec {
  pname = "slog";
  version = "0.1.0";
  src = srcDir + pname;
  pyproject = true;
  buildInputs = [
    rich
    uv
  ];
  propagatedBuildInputs = buildInputs;
  meta = with pkgs.lib; {
    licences = [ licences.mit ];
    platforms = platforms.x86_64 ++ platforms.aarch;
  };
}
