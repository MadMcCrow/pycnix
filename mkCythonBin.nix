# mkCythonBin.nix
# parameters :
#   pkgs    : given by the flake, cannot be used by user
#   python  : the python version to use
#   pname, version : mkDerivation arguments (TODO: allow for name/pname automatic dispatch)
# usage :
#   mkCythonBin {pname = "test"; version = "0.1", main =  "test" ; modules = [./test.py]; python = pkgs.python3};
# note :
#   we could use pkgs.writers.writePython3Bin instead : 
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./file.py);
pkgs:
{python ? pkgs.python310, name ? "", pname ? "", version ? "", main, modules, libraries ? [ ] }:
with builtins;
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
  platincdir="${python}/include/python${pyVersion}";
  libdirBase= "${python}/lib";
  libdirOS= "${python}/lib/python${pyVersion}/config-${pyVersion}-" + (if isDarwin then "darwin" else "x86_64-linux-gnu");
  linkForShared =if isDarwin then "" else "-Xlinker -export-dynamic";
  deps = map (x : if isString x then python.pkgs."${x}" else x) libraries;
  depsLibStr = concatStringsSep " " (map (x: "-L${x}/lib") deps);
  libs = "-lcrypt -ldl -L${pkgs.libxcrypt}/lib ${depsLibStr} -lm";
  sysLibs = "-lm";

  # final commands :
  cythonize = "${cython}/bin/cython -f --embed -o ${name}.c $srcList";
  cc = "${gcc}/bin/gcc  -fPIC -c ${name}.c -I${incdir} -I${platincdir}";
  ld = "${gcc}/bin/gcc -o ${name} ${name}.o -L${libdirBase} -L${libdirOS} -lpython${pyVersion} ${libs} ${sysLibs} ${linkForShared}";


  # inputs
  nativeBuildInputs = [ python cython pkgs.gcc ] ++ deps;
  buildInputs = [ python ] ++ deps;     # run-time dependencies

 
  # Create an executable Compiled Python script
  # Takes a attrs with : 
  #   - a name ( for the derivation )
  #   - a main module name (usually your script without the .py)
  #   - a list of modules to compile
  #   - potential libraries to append (not tested)
  #
in pkgs.stdenv.mkDerivation ({
  inherit version nativeBuildInputs buildInputs;
  propagatedBuildInputs = buildInputs;

  src = modules;

  unpackPhase = ''
    for srcFile in $src; do
    srcList+=$(stripHash $srcFile)
    cp $srcFile $(stripHash $srcFile)
    done
  '';

  # we could cythonize everything, no need for manual gcc :
  # ${cython}/bin/cythonize --embed -if3 --no-docstrings *.py
  # instead we do it manually :
  buildPhase = ''
      ${cythonize}
      ${cc}
      echo "${ld}"
      ${ld}
  '';

  # copy all so files and add our main
  installPhase = ''
    mkdir -p "$out/bin"
    cp ${name} $out/bin/
  '';
} //( if name != "" then {inherit name;} else if  pname != "" then {inherit pname; } else throw "you must either define pname and version or name" ))