# Apps every desktop gets: browser, password manager, Discord, Signal, Spotify, Notion, Krita, Inkscape, image viewer, file manager
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
    # Notion has no Linux app, so this opens notion.so as an app window in
    # Helium (no tabs or address bar). The icon comes from Papirus.
    (makeDesktopItem {
      name = "notion";
      desktopName = "Notion";
      comment = "Notes, docs and wikis";
      exec = "helium --app=https://www.notion.so";
      icon = "notion";
      categories = [ "Office" ];
    })
    bitwarden-desktop # password manager
    discord
    signal-desktop # messaging
    spotify
    krita # painting
    inkscape # vector graphics
    celluloid # video player, a GTK front end for mpv; the default for video
    loupe # image viewer (GNOME Image Viewer); the default for images
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
