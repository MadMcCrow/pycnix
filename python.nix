# Python.nix
# usage :
#   python.mkPyScript {name = "test"; main =  "test" ; modules = [./test.py];};
# note :
#   we could use pkgs.writers.writePython3Bin instead : 
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./file.py);
{pkgs, ...} :
with builtins;
let 
python = pkgs.python310;
cython = pkgs.python310Packages.cython_3;


# If we want to have control over the compilation process
# We may use this :
# 
# incdir = "${python3}/include/python3.10";
# platincdir="${python3}/include/python3.10";
# libdir1= "${python3}/lib";
# libdir2= "${python3}/lib/python3.10/config-3.10-x86_64-linux-gnu";
# pylib= "python3.10";
# linkForShared = "-Xlinker -export-dynamic";
# libs = "-lcrypt -ldl -L/nix/store/vjfvgq4qianhvj2paph2xsmy1hbjbarm-libxcrypt-4.4.30/lib -lm";
# sysLibs = "-lm";
# gcc = pkgs.gcc;
# cythonize = "${cython}/bin/cython --embed ${name}.py ";
# cc = "${gcc}/bin/gcc -c ${name}.c -I${incdir} -I${platincdir}";
# ld = "${gcc}/bin/gcc -o ${name} ${name}.o -L${libdir1} -L${libdir2} -l${pylib} ${libs} ${sysLibs} ${linkForShared}";

in
{
  # Create an executable Compiled Python script
  # Takes a attrs with : 
  #   - a name ( for the derivation )
  #   - a main module name (usually your script without the .py)
  #   - a list of modules to compile
  #   - potential libraries to append (not tested)
  #
  mkPythonBin = {name , main , modules , libraries ? [] } :
      let
      # TODO clean inputs
      nativeBuildInputs = [
          python
          cython
          pkgs.gcc
          ] ++ libraries;
      buildInputs = nativeBuildInputs;     
      # python script to launch our compiled module
      runpy = pkgs.writers.writePython3 "${name}" {inherit libraries; flakeIgnore=["F401"]; } ''
      import ${main}
      '';
      in
      pkgs.stdenv.mkDerivation {
        inherit name nativeBuildInputs buildInputs;
      
      src = modules;

      unpackPhase = ''
        for srcFile in $src; do
          cp $srcFile $(stripHash $srcFile)
        done
        '';

        # cythonize everything, no need for manual gcc
        # TODO : use manual gcc for custom build options      
        buildPhase = ''
        ${cython}/bin/cythonize -if3 --no-docstrings *.py
        '';

        # copy all so files and add our main
        installPhase = ''
        mkdir -p "$out/bin"
        for i in *.so; do
          cp $i $out/bin/
        done
        cp ${runpy} $out/bin/${name}
        '';
      };
}