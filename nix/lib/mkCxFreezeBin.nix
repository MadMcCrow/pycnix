# mkCxFreezBin.nix
# parameters :
#   pkgs      : given by the flake, cannot be used by user
#   python    : the python version to use
#   main      : the main python file
pkgs:
{
  python ? pkgs.python311,
  includes,
  main ? "__main__.py",
  ...
}@args:
let

  # a fixed freezer that won't complain about dates being before 1980 (store is epoch)
  freezer = python.pkgs.cx_Freeze.overrideAttrs (
    final: prev: {
      postInstall = ''
        substituteInPlace $out/lib/python${python.pythonVersion}/site-packages/cx_Freeze/freezer.py \
        --replace "mtime = int(file_stat.st_mtime) & 0xFFFF_FFFF" "mtime = int(time.time()) & 0xFFFF_FFFF"
      '';
    }
  );

in
# implementation
pkgs.stdenv.mkDerivation (
  args
  // rec {

    # extract pname from args
    pname = if args ? "pname" then args.pname else (builtins.parseDrvName args.name).name;

    nativeBuildInputs = [
      freezer
    ] ++ (pkgs.lib.lists.optionals (args ? nativeBuildInputs) args.nativeBuildInputs);
    # buildInputs = libs; # dependencies must be included in the freeze
    # unpack files and folders alike !

    buildPhase = ''
      mkdir -p ./build
      ${freezer}/bin/cxfreeze ${main} ${
        if (builtins.length includes) > 0 then
          "--includes ${builtins.concatStringsSep "," includes}"
        else
          ""
      } \
      --zip-include-packages=* \
      --target-name=${pname}   \
      --target-dir=./build     \
      --compress -s
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -r ./build/* $out/bin
    '';
  }
)
