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
in { pname, version, src, includes, main ? "__main__.py", nativeBuildInputs ? [] } : pkgs.stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = nativeBuildInputs ++ [ freezer ];
  # buildInputs = libs; # dependencies must be included in the freeze
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
    ${freezer}/bin/cxfreeze ${main} ${
      if (length includes) > 0 then
        "--includes ${concatStringsSep "," includes}"
      else
        ""
    } \
    --zip-include-packages=* \
    --target-name=${pname}   \
    --target-dir=./build     \
    --compress -s
  '';

  installPhase = ''
  dasdaw
  #install -Dm 755 ./build/${pname} $out/bin/${pname}
  mkdir -p $out/bin
  cp -r ./build/* $out/bin
  '';
}
