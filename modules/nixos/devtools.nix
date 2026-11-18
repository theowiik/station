# Command line development tools. This is the switch; the tools and their
# configuration are in modules/home/devtools.nix (Home Manager).
{ config, lib, ... }:
{
  options.my.devtools.enable = lib.mkEnableOption "command line development tools (git, neovim, search and Nix tools)";

  # Unfree tools installed by modules/home/devtools.nix. Home Manager uses the
  # system pkgs (useGlobalPkgs), so they are allowed here.
  config = lib.mkIf config.my.devtools.enable {
    my.unfreePackages = [ "claude-code" ];
  };
}
