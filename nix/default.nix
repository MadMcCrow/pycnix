# nix/default.nix
# import all nix functions
{ system, pkgs, ... }@args:
with (pkgs) lib;
let
  # supported pythons :
  # asyncio runners are available starting with python 3.11
  pythons = with pkgs; [
    python311
    python312
  ];

  # lib
  args = args // { inherit lib; } ;

in
rec {

  # import modules :

  ## map all packages to either python
  packages.${system} = builtins.listToAttrs (
    map (x: {
      name = lib.getName x;
      value = callPackage ./packages (args // { python = x; });
    }) pythons
  );

  ## apps need packages :
  apps.${system} = pkgs.callPackages ./apps.nix (args // packages.${system});

  ## libs are the same for all systems :
  libs = pkgs.callPackages ./lib args;

  ## shell :
  shells.default = pkgs.callPackage ./shell.nix args;
}
