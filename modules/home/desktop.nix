# Desktop helpers that run in both sessions, user folders and default apps.
{ lib, osConfig, ... }:
let
  # Hide a system XDG autostart entry for this user.
  hideAutostart = file: {
    "autostart/${file}".text = ''
      [Desktop Entry]
      Type=Application
      Name=${file}
      Hidden=true
    '';
  };
in
lib.mkIf osConfig.my.desktop.enable {
  # Mount USB drives as soon as they are plugged in, with a notification.
  # No tray icon, because that would make the service wait for a tray.target
  # that neither session starts. Mounted drives show up in the file manager.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
  };

  # The network and Bluetooth tray applets would autostart in the niri session
  # too, where DMS is already the network secret agent and the Bluetooth
  # pairing agent. The Hyprland config starts both applets itself.
  xdg.configFile = hideAutostart "nm-applet.desktop" // hideAutostart "blueman.desktop";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };
}
