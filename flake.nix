# pycnix (picnics) is a simple flake to help package and run python scripts
# mkCythonBin  : let you compile complex scripts with cython
# mkPipInstall : helps with having programs from pip
{
  description = "pycnix, collection of python helper functions";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }@inputs:
    with builtins;
    let
      # support systems
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
        (system: function nixpkgs.legacyPackages.${system});

      # sub modules
      modules = [
        ./lib/mkCythonBin.nix
        ./lib/mkPipInstall.nix
        ./lib/mkCxFreezeBin.nix
        ./lib/mkPyInstaller.nix
      ];

    in {

      # expose functions
      lib = forAllSystems (pkgs:
        listToAttrs (map (x: {
          name = elemAt (elemAt (split ".*/.*-(.*).nix" "${x}") 1) 0;
          value = import x pkgs;
        }) modules));

      packages = forAllSystems (pkgs: {
        pyinstaller = import ./packages/pyinstaller.nix {
          inherit pkgs;
          python = pkgs.python3;
        };
      });

      # shell for testing and develop pycnix
      devShells = forAllSystems
        (pkgs: { default = import ./shell.nix { inherit pkgs; }; });
    };
}
