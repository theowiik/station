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

  # Common video formats, opened with Celluloid.
  videoTypes = [
    "video/mp4"
    "video/x-matroska"
    "video/webm"
    "video/x-msvideo"
    "video/quicktime"
    "video/mpeg"
    "video/x-flv"
    "video/x-ms-wmv"
    "video/ogg"
    "video/3gpp"
    "video/mp2t"
    "video/x-m4v"
  ];

  # Common image formats, opened with Loupe.
  imageTypes = [
    "image/png"
    "image/jpeg"
    "image/gif"
    "image/webp"
    "image/avif"
    "image/heic"
    "image/jxl"
    "image/bmp"
    "image/tiff"
    "image/svg+xml"
  ];
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

  # EasyEffects in the background, with DeepFilterNet noise suppression on the
  # microphone. Apps that record from the default mic get the cleaned-up
  # sound. Open the EasyEffects window to tune it or add an equalizer.
  services.easyeffects = {
    enable = true;
    preset = "noise-cancelling";
    extraPresets.noise-cancelling.input = {
      blocklist = [ ];
      plugins_order = [ "deepfilternet#0" ];
      # The EasyEffects defaults; a lower attenuation-limit (in dB) keeps
      # more of the background if your voice starts to sound processed.
      "deepfilternet#0" = {
        bypass = false;
        input-gain = 0.0;
        output-gain = 0.0;
        attenuation-limit = 100.0;
        min-processing-threshold = -15.0;
        max-erb-processing-threshold = 35.0;
        max-df-processing-threshold = 35.0;
        min-processing-buffer = 0;
        post-filter-beta = 0.02;
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
    }
    # Celluloid (installed in modules/nixos/desktop/apps.nix) for video.
    // lib.genAttrs videoTypes (_: "io.github.celluloid_player.Celluloid.desktop")
    # Loupe (modules/nixos/desktop/apps.nix) for images.
    // lib.genAttrs imageTypes (_: "org.gnome.Loupe.desktop");
  };
}
