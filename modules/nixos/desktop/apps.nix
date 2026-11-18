# Apps every desktop gets: browser, password manager, Discord, Signal, Spotify, file manager
# and small GUI tools.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.my.desktop.enable {
  environment.systemPackages = with pkgs; [
    (callPackage ../../../pkgs/helium.nix { }) # browser, wraps the official AppImage
    bitwarden-desktop # password manager
    discord
    signal-desktop # messaging
    spotify
    celluloid # video player, a GTK front end for mpv; the default for video
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

  networking.firewall.allowedTCPPorts = [ 57621 ];
  networking.firewall.allowedUDPPorts = [ 57621 ];

  my.unfreePackages = [
    "discord"
    "spotify"
  ];
}
