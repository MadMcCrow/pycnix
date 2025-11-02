{
  description = "Develop Python on Nix with uv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      pyproject-nix,
      uv2nix,
      pyproject-build-systems,
      self,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      forAllSystems = nixpkgs.lib.genAttrs lib.systems.flakeExposed;
    in
    {

      packages = forAllSystems (system: import ./nix/packages.nix (inputs // { inherit system lib; }));
      apps = forAllSystems (system: import ./nix/apps.nix (inputs // { inherit system lib; }));
    };
}
