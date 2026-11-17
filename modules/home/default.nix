# Home Manager modules for the main user.
#
# Each module follows the matching NixOS switch (osConfig.my.*), so a host
# turns a feature on in one place and gets both the system and the user side.
{
  imports = [
    ./theme.nix
    ./desktop.nix
    ./terminal.nix
    ./niri.nix
    ./dms.nix
    ./hyprland.nix
    ./shell.nix
    ./devtools.nix
  ];
}
