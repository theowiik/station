# station-vm: a Hyper-V guest on the Windows host, for testing this repo
# before installing it on station.
#
# Hyper-V because it is already on (WSL2 and Docker use it), and VirtualBox
# runs too slowly on top of it to even boot.
#
# The same desktop, shell and tools as station, without the NVIDIA driver and
# the gaming extras. Hyper-V has no 3D acceleration for Linux guests, so both
# sessions render in software (Mesa llvmpipe): usable for testing the config,
# not fast. The login screen starts Hyprland by default because niri may not
# render well in a VM. Niri stays installed and can be picked at the login
# screen (F3).
{ ... }:
let
  # Language, regional formats, time zone and keyboard, in one place.
  locale = {
    timeZone = "Europe/Stockholm";
    language = "en_US.UTF-8"; # messages and menus
    formats = "sv_SE.UTF-8"; # dates, numbers, currency, paper size, units
    keyboardLayout = "se";
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "station-vm";
  my.locale = locale;

  # The same login name as on station. Create this user in the NixOS
  # installer too, so it has a password (see README.md).
  my.user.name = "theo";

  my.desktop.enable = true;
  my.desktop.defaultSession = "hyprland";
  # The hardware cursor is often invisible in VMs.
  my.desktop.hyprland.softwareCursor = true;
  my.shell.enable = true;
  my.devtools.enable = true;

  # Hyper-V guest support: the Hyper-V kernel modules in the initrd (storage,
  # network, display, keyboard, mouse) and the integration services daemons.
  virtualisation.hypervGuest.enable = true;

  system.stateVersion = "26.05";
}
