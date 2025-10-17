# pycnix (picnics) is a simple flake to help package and run python scripts
{
  description = "pycnix, collection of python helper functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # support systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      flake =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.${system} = builtins.listToAttrs (
            map (x: {
              name = x;
              value = pythonOverride (builtins.getAttr x pkgs);
            }) pythons
          );

          # shell for testing and develop pycnix
          devShells = forAllSystems (pkgs: {
            default = import ./shell.nix { inherit pkgs; };
          });
        };
    in
    # for each supported system
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } (map flake systems);
}
