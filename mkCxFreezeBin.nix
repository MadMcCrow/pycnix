# mkCythonBin.nix
# parameters :
#   pkgs      : given by the flake, cannot be used by user
#   python    : the python version to use
#   main      : the main python file
#   modules   : python modules to include (list of strings)
#   buildPath : where to build, only modify if your sources already contains a folder name build 
pkgs:
{ python ? pkgs.python311
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

  # include command for cxfreeze
  includes = if (length modules) > 0 then 
  "--includes ${concatStringsSep "," modules}"
  else "";

  # implementation
in pkgs.stdenv.mkDerivation ({
  nativeBuildInputs = nativeBuildInputs
  ++ [ python.pkgs.cx_Freeze ];
  unpackPhase = "
  cp -r $src ./ 
  ls -la
  ";
  buildPhase = ''
    mkdir -p ./${buildPath}
    ${python.pkgs.cx_Freeze}/bin/cxfreeze -c ${main} ${includes} --target-name=${outbin} --target-dir=./${buildPath}
  '';
  installPhase = ''
    mkdir -p $out/bin
    ls -la ./${buildPath}
    cp -r ./${buildPath}/* $out/bin
  '';
} // buildArgs)
