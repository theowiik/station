# Apps every desktop gets: browsers, Discord, file manager and small GUI tools.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.my.desktop.enable {
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    (callPackage ../../../pkgs/helium.nix { }) # browser, wraps the official AppImage
    discord
    nautilus # file manager, also the file chooser of the GNOME portal
    file-roller # archives
    pavucontrol # volume control
    networkmanagerapplet # nm-connection-editor; the tray applet runs only in Hyprland
    wl-clipboard
    grim # screenshots in Hyprland (niri has its own)
    slurp
    playerctl # media keys
    libnotify # notify-send
  ];

  my.unfreePackages = [ "discord" ];
}
