# Command line development tools. This is the switch; the tools and their
# configuration are in modules/home/devtools.nix (Home Manager).
{ lib, ... }:
{
  options.my.devtools.enable = lib.mkEnableOption "command line development tools (git, neovim, search and Nix tools)";
}
