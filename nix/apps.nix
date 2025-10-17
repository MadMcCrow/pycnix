# wrap pkgs into apps :
{ python311, ... }:
let
  python = python311;
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
