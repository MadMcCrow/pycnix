# pycnix (picnics) is a simple flake to help package and run python scripts
{
  description = "pycnix, collection of python helper functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # pyproject helps build python apps
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # uv 2 nix allows creating a whole workspace of projects
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      pyproject-nix,
      uv2nix,
      ...
    }@inputs:
    let
      # support systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      flake =
        system:
        import ./nix {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (nixpkgs) lib;
          inherit pyproject-nix uv2nix self;
        };
    in
    # for each supported system
    builtins.foldl' (x: y: nixpkgs.lib.recursiveUpdate x y) { } (map flake systems);
}
