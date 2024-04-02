# this flakes uses godot-flake
{
  description = "A project that uses pycnix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pycnix.url = "github:MadMcCrow/pycnix";
    pycnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, pycnix, ... }@inputs:
    let
      # supported systems
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # default system-agnostic flake implementation :
      flake = system:
        let

          pycnix-lib = pycnix.lib."${system}";
          pkgs = import nixpkgs { inherit system; };
          myProgram = pycnix-lib.mkCythonBin {
            python = pkgs.python311;
            pname = "my-cython-app";
            version = "0.1";
            main = "__main__.py";
            src = self;
            libraries = [ "rtp" ];
          };

        in {
          # implement your flake here ;)
          packages."${system}" = { default = myProgram; };
        };

      # gen for all systems :
    in foldl' (x: y: godot-flake.inputs.nixpkgs.lib.recursiveUpdate x y) { }
    (map flake systems);
}
