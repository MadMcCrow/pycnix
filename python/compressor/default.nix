# build as package
{ python311Packages, ffmpeg, ... }:
with python311Packages;
buildPythonPackage rec {
  pname = "compressor";
  version = "1.0";
  src = ./.;
  buildInputs = [
    rich
    sh
    ffmpeg
  ];
  propagateBuildInputs = buildInputs;
}
