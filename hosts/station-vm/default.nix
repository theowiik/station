# station-vm: a VirtualBox guest on the Windows host, for testing this repo
# before installing it on station.
#
# The same desktop, shell and tools as station, without the NVIDIA driver and
# the gaming extras. The login screen starts Hyprland by default because niri
# may not render in VirtualBox. Niri stays installed and can be picked at the
# login screen (F3).
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

  # TODO(user): the same login name as on station. Create this user in the
  # NixOS installer too, so it has a password (see README.md).
  my.user.name = "theowiik";

  my.desktop.enable = true;
  my.desktop.defaultSession = "hyprland";
  # The hardware cursor is often invisible in VirtualBox.
  my.desktop.hyprland.softwareCursor = true;
  my.shell.enable = true;
  my.devtools.enable = true;

  # VirtualBox Guest Additions: the display follows the VM window size
  # (VMSVGA), shared clipboard, drag and drop, and shared folders (vboxsf).
  # Checked against the NixOS wiki VirtualBox page and the nixpkgs 26.05
  # module, where clipboard and drag and drop are on by default.
  virtualisation.virtualbox.guest = {
    enable = true;
    clipboard = true;
    dragAndDrop = true;
  };

  system.stateVersion = "26.05";
}
