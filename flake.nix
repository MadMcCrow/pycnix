# pycnix (picnics) is a simple flake to let you compile complex scripts with cython
# and run them in a nix environment 
{
  description = "pycnix, function to build python script with cython";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }@inputs:
    let
      # only linux supported for now
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
        (system: function nixpkgs.legacyPackages.${system});
    in {
      lib = forAllSystems (pkgs : import ./python.nix { inherit pkgs;});
      devShells = forAllSystems (pkgs: import ./shell.nix { inherit pkgs; });
    };
}