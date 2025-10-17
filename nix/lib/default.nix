# expose libs
{ pkgs, python, ... }:
{
  # TODO :
  mkCxFreezeBin = pkgs.callPackage ./mkCxFreezeBin.nix { };
}
