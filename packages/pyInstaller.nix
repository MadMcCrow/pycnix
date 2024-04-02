# pyinstaller.nix
# provide pyinstaller python module
{ pkgs, python }:
let
  # the hooks
  pyinstaller-hooks-contrib = python.pkgs.buildPythonPackage rec {
    version = "2024.3";
    pname = "pyinstaller-hooks-contrib";
    src = python.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-0YZXwpJnxjVjqWuPx422uprkCvZwKssvjIcd8Sx1tgs=";
    };
    propagatedBuildInputs = (with python.pkgs; [ packaging pip ]);
  };

  # implementation
in python.pkgs.buildPythonPackage rec {
  version = "6.5.0";
  pname = "pyinstaller";
  src = python.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-seVRE8WkDLcEHJCKV/IS8+vT5ETbskXKL5HYanbavsU=";
  };
  propagatedBuildInputs = [ pyinstaller-hooks-contrib pkgs.zlib ]
    ++ (with python.pkgs; [
      packaging
      pip
      altgraph
      setuptools
      pyqt5
      pyqt5-stubs
      qtpy
      matplotlib
    ]) ++ (pkgs.lib.lists.optionals (pkgs.stdenv.isDarwin)
      [ pkgs.darwin.binutils ])
    ++ (pkgs.lib.lists.optionals (pkgs.stdenv.isLinux) [
      pkgs.binutils
      pkgs.glibc
    ]);

  dontUseSetuptoolsCheck = true;
  # for lib.getExe
  meta = {
    mainProgram = "$out/bin/${pname}";
    description = "pyinstaller is a builder for python packages";
  };
}
