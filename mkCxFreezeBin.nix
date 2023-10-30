# mkCythonBin.nix
# parameters :
#   pkgs      : given by the flake, cannot be used by user
#   python    : the python version to use
#   main      : the main python file
#   modules   : python modules to include (list of strings)
#   buildPath : where to build, only modify if your sources already contains a folder name build 
pkgs:
{ python ? pkgs.python311
, src
, main
, modules
, buildPath ? "build"
, nativeBuildInputs ? [ ]
, ... } @args :
with builtins;
let
  # shortcut
  condAttr = n: s: d: if hasAttr n s then getAttr n s else d;

  outbin = condAttr "name" args (condAttr "pname" args (throw "please define either name or pname"));

  # remove the attributes we already use
  buildArgs = removeAttrs args [
    "python"
    "main"
    "modules"
    "buildPath"
    "nativeBuildInputs"
  ];

  # a fixed freezer that won't complain about dates being before 1980 (store is epoch)
  freezer = python.pkgs.cx_Freeze.overrideAttrs (final: prev: {
  postInstall =  ''
  substituteInPlace $out/lib/python3.11/site-packages/cx_Freeze/freezer.py \
  --replace "mtime = int(file_stat.st_mtime) & 0xFFFF_FFFF" "mtime = int(time.time()) & 0xFFFF_FFFF"
  '';
  });

  # include command for cxfreeze
  includes = if (length modules) > 0 then 
  "--includes ${concatStringsSep "," modules}"
  else "";


# implementation
in pkgs.stdenv.mkDerivation ({
  nativeBuildInputs = nativeBuildInputs
  ++ [ freezer ];
  # unpack files and folders alike !
  unpackPhase = ''
    if [ -d $src ]; then
      cp -r $src/* ./
    else 
      cp $src ./$(stripHash $src)
    fi
    touch -a -m ./*
  '';

  buildPhase = ''
    ls -la
    mkdir -p ./${buildPath}
    ${freezer}/bin/cxfreeze -c ${main} ${includes} --target-name=${outbin} --target-dir=./${buildPath}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r ./${buildPath}/* $out/bin
  '';
} // buildArgs)
