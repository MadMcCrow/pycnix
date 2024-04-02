# mkCythonBin.nix
# parameters :
#   pkgs    : given by the flake, cannot be used by user
#   python  : the python version to use
#   pname, version : mkDerivation arguments
# usage :
#   mkCythonBin {pname = "test"; version = "0.1", main =  "test" ; python = pkgs.python3};
# note :
#   we could use pkgs.writers.writePython3Bin instead : 
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./file.py);
pkgs:
{ python ? pkgs.python311, main, src, libraries ? [ ], nativeBuildInputs ? [ ]
, ... }@args:
let
  # programs
  gcc = pkgs.gcc;
  cython = python.pkgs.cython_3;

  # crossPlatform support
  isDarwin = pkgs.system == "aarch64-darwin";

  # for example : "3.10" (removes 'python' from 'python3.10')
  pyVersion = pkgs.lib.strings.removePrefix "python" "${python.executable}";

  # compilation arguments
  incdir = "${python}/include/python${pyVersion}";
  platincdir = "${python}/include/python${pyVersion}";
  libdirBase = "${python}/lib";
  libdirOS = "${python}/lib/python${pyVersion}/config-${pyVersion}-"
    + (if isDarwin then "darwin" else "x86_64-linux-gnu");
  linkForShared = if isDarwin then "" else "-Xlinker -export-dynamic";

  # dependancies
  deps =
    map (x: if builtins.isString x then python.pkgs."${x}" else x) libraries;
  depsLibStr = builtins.concatStringsSep " " (map (x: "-L${x}/lib") deps);
  libs = "-lcrypt -ldl -L${pkgs.libxcrypt}/lib ${depsLibStr} -lm";
  sysLibs = "-lm";

  # Create an executable Compiled Python script
  # Takes a attrs with : 
  #   - a name ( for the derivation )
  #   - a main module name (usually your script without the .py)
  #   - a list of modules to compile
  #   - potential libraries to append (not tested)
  #
in pkgs.stdenv.mkDerivation (args // rec {
  inherit src;
  pname = if args ? "pname" then
    args.pname
  else
    (builtins.parseDrvName args.name).name;

  # dependencies :
  nativeBuildInputs = [ python cython pkgs.gcc ] ++ deps;
  buildInputs = [ python ] ++ deps;
  propagatedBuildInputs = nativeBuildInputs;
  runtimeDependencies = deps;

  # unpack stuff :
  unpackPhase = ''
    if [ -d $src ]; then
      cp -r $src/* ./
    else 
      cp $src ./$(stripHash $src)
    fi
    find . -type f -exec touch -a -m {} +
  '';

  # we could cythonize everything, no need for manual gcc :
  # ${cython}/bin/cythonize --embed -if3 --no-docstrings *.py
  # instead we do it manually :
  buildPhase = ''
    # cythonize
    ${cython}/bin/cython -f --embed -o ${pname}.c $srcList
    # CC
    ${gcc}/bin/gcc  -fPIC -c ${pname}.c \
    -I${incdir} -I${platincdir}
    # LD
    ${gcc}/bin/gcc -o ${pname} ${pname}.o \
    -L${libdirBase} -L${libdirOS} \
    -lpython${pyVersion} ${libs} ${sysLibs} \
    ${linkForShared}
  '';

  # copy the resulting binary
  installPhase = ''
    install -Dm 755 ${pname} $out/bin/${pname}
  '';

  # for lib.getExe
  meta.mainProgram = "$out/bin/${pname}";
})
