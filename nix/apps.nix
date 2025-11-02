# wrap pkgs into apps :
{ ... } @args :
let
  packages = import ./packages.nix args;
in
{
  #pysubfixer :
  pysubfixer-gui = {
    type = "app";
    program = "${packages.pysubfixer}/bin/pysubfixer-gui";
  };
  pysubfixer-cli = {
    type = "app";
    program = "${packages.pysubfixer}/bin/pysubfixer-cli";
  };
}
