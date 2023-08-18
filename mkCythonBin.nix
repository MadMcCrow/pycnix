# mkCythonBin.nix
# usage :
#   mkCythonBin {name = "test"; main =  "test" ; modules = [./test.py];};
# note :
#   we could use pkgs.writers.writePython3Bin instead : 
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./file.py);
pkgs: python:
{ name, main, modules, libraries ? [ ] }:
with builtins;
let

  cython = python.pkgs.cython_3;
  
  # python3.10
  pythonVersionText = "${python.executable}";

  # build time dependencies
  deps = map (x : if isString x then python.pkgs."${x}" else x) libraries;

  depsLibStr = map (x: "-L${x}/lib") deps;

  # If we want to have control over the compilation process
  # We may use this :
  incdir = "${python}/include/${pythonVersionText}";
  platincdir="${python}/include/${pythonVersionText}";
  libdir1= "${python}/lib";
  libdir2= "${python}/lib/${pythonVersionText}/config-3.10-x86_64-linux-gnu";
  pylib= "python3.10";
  linkForShared = "-Xlinker -export-dynamic";
  libs = "-lm -ldl" ;# "-lcrypt -ldl -L${pkgs.libxcrypt}/lib ${depsLibStr} -lm";
  sysLibs = "-lm";
  gcc = pkgs.gcc;



  nativeBuildInputs = [ python cython pkgs.gcc ] ++ deps;
  buildInputs = [ python ] ++ deps;     # run-time dependencies

 
  # Create an executable Compiled Python script
  # Takes a attrs with : 
  #   - a name ( for the derivation )
  #   - a main module name (usually your script without the .py)
  #   - a list of modules to compile
  #   - potential libraries to append (not tested)
  #
in pkgs.stdenv.mkDerivation {
  inherit name nativeBuildInputs buildInputs;

  src = modules;

  unpackPhase = ''
    for srcFile in $src; do
    srcList+=$(stripHash $srcFile)
    cp $srcFile $(stripHash $srcFile)
    ls -la
    done
  '';

  # cythonize everything, no need for manual gcc :
  # ${cython}/bin/cythonize --embed -if3 --no-docstrings *.py
  # instead we do it manually :
  buildPhase = let 
      cythonize = "${cython}/bin/cython -f --embed -o ${name}.c $srcList";
      cc = "${gcc}/bin/gcc -c ${name}.c -I${incdir} -I${platincdir}";
      ld = "${gcc}/bin/gcc -o ${name} ${name}.o -L${libdir1} -L${libdir2} -l${pylib} ${libs} ${sysLibs} ${linkForShared}";
    in
  ''
      ls -la
      echo "${cythonize}"
      ${cythonize}
      ls -la
      ${cc}
      ${ld}
      ls -la
  '';

  # copy all so files and add our main
  installPhase = ''
    mkdir -p "$out/bin"
    cp ${name} $out/bin/
    ls -la $out/bin
  '';
}
