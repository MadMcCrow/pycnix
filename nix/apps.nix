# wrap pkgs into apps :
{ pkgs, ... }:
let
  python = pkgs.python312;
in
{
  #pysubfixer :
  pysubfixer-gui = {
    type = "app";
    program = "${python.pysubfixer}/bin/pysubfixer-gui";
  };
  pysubfixer-cli = {
    type = "app";
    program = "${python.pysubfixer}/bin/pysubfixer-cli";
  };
}
