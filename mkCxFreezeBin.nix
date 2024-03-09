# mkCythonBin.nix
# parameters :
#   pkgs      : given by the flake, cannot be used by user
#   python    : the python version to use
#   main      : the main python file
#   modules   : python modules to include (list of strings)
#   buildPath : where to build, only modify if your sources already contains a folder name build 
{ pkgs, lib, python ? pkgs.python311, ... }@args:
with builtins;
let

  # a fixed freezer that won't complain about dates being before 1980 (store is epoch)
  freezer = python.pkgs.cx_Freeze.overrideAttrs (final: prev: {
    postInstall = ''
      substituteInPlace $out/lib/python${python.pythonVersion}/site-packages/cx_Freeze/freezer.py \
      --replace "mtime = int(file_stat.st_mtime) & 0xFFFF_FFFF" "mtime = int(time.time()) & 0xFFFF_FFFF"
    '';
  });

  # implementation
in { src, includes, main, ... }@args:
(pkgs.stdenv.mkDerivation args).overrideAttrs (prev: {
  nativeBuildInputs = prev.nativeBuildInputs ++ [ freezer ];

  # unpack files and folders alike !
  unpackPhase = ''
    if [ -d $src ]; then
      cp -r $src/* ./
    else 
      cp $src ./$(stripHash $src)
    fi
    find . -type f -exec touch -a -m {} +
  '';

  buildPhase = ''
    mkdir -p ./build
    ${freezer}/bin/cxfreeze -c ${main} ${
      if (length includes) > 0 then
        "--includes ${concatStringsSep "," includes}"
      else
        ""
    }\
    --target-name=${
      if prev ? pname then prev.pname else lib.strings.getName (prev.name)
    } --target-dir=./build
  '';

  installPhase = lib.strings.concatLines [
    (lib.strings.optionalString (prev ? installPhase) prev.installPhase)
    "install -m755 -D ./build/* $out/bin"
  ];
})
