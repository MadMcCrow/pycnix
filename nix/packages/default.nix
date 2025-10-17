# python packages, as added to the default pkgs python package
{
  system,
  pkgs,
  python,
  ...
}:
let
  # source directory :
  srcDir = "../../python/";

in
# override python packages
python.override {
  packageOverrides =
    final: prev:
    builtins.listToAttrs (
      map
        (
          x:
          let
            pkg = pkgs.callPackage x { inherit python srcDir; };
          in
          {
            name = pkgs.lib.getName pkg;
            value = pkg;
          }
        )
        [
          ./slog.nix
          ./pysubfixer.nix
          ./pyinstaller.nix
          ./pyremdup.nix
        ]
    );

}
