# nix/default.nix
# import all nix functions
{
  system,
  pkgs,
  lib,
  uv2nix,
  ...
}@args:
let
  # supported pythons :
  # asyncio runners are available starting with python 3.11
  # we have to use strings as we cannot infer the name from the attribute set
  # lib.getName give "Python3" for all of them
  pythons = with pkgs; [
    "python311"
    "python312"
  ];

  # create a uv2nix workspace :
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ../python; };

in
rec {

  # import modules :

  ## map all packages to either python
  packages.${system} = builtins.listToAttrs (
    map (x: {
      name = x;
      value = pkgs.callPackage ./packages (args // { python = pkgs.${x}; });
    }) pythons
  );

  ## apps need packages :
  apps.${system} = pkgs.callPackages ./apps.nix (packages.${system});

  ## libs are the same for all systems :
  libs = pkgs.callPackages ./lib args;

  ## shell :
  shells.default = pkgs.callPackage ./shell.nix args;
}
