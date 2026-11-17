# Wayland sessions, the login screen and the desktop shell.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop;
  theme = config.my.theme;
  niri = config.programs.niri.package;
  hyprland = config.programs.hyprland.package;

  # What the login screen runs for each session.
  sessionCommands = {
    niri = lib.getExe' niri "niri-session";
    hyprland = lib.getExe' hyprland "start-hyprland";
  };

  # The sessions the login screen offers. Only these two: the Hyprland
  # package also ships a UWSM session, which this config does not set up.
  sessionDir = pkgs.runCommand "greeter-wayland-sessions" { } ''
    mkdir -p $out
    cp ${niri}/share/wayland-sessions/niri.desktop $out/
    cp ${hyprland}/share/wayland-sessions/hyprland.desktop $out/
  '';
in
lib.mkIf cfg.enable {
  # Niri from nixpkgs. The module also sets up what the niri wiki asks for:
  # xdg-desktop-portal-gnome (screen sharing) and -gtk (fallback), with
  # Nautilus as the file chooser, gnome-keyring for the Secret portal, polkit
  # and dconf. The polkit agent comes from DMS.
  programs.niri.enable = true;

  # Niri starts xwayland-satellite on demand for X11 apps (Steam, most games)
  # as soon as it is on PATH (niri 25.08 or newer, xwayland-satellite 0.7 or
  # newer). Niri also sets DISPLAY itself, so nothing in this repo sets it.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  # Hyprland from nixpkgs as the fallback session, started directly (no
  # UWSM). The module adds xdg-desktop-portal-hyprland for screen sharing.
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  # DankMaterialShell: bar, launcher, notifications, control center, lock
  # screen, wallpaper, and the polkit, Bluetooth pairing and network secret
  # agents. It runs only in the niri session: the service is wanted by
  # niri.service, the declarative form of the upstream instruction
  # `systemctl --user add-wants niri.service dms`.
  programs.dms-shell = {
    enable = true;
    systemd.target = "niri.service";
    # No matugen, so DMS does not write theme files for other apps. Those are
    # themed from my.theme by Home Manager (modules/home/theme.nix).
    enableDynamicTheming = false;
  };

  environment.sessionVariables = {
    # Electron and Chromium apps (Discord) run as native Wayland clients.
    NIXOS_OZONE_WL = "1";
    # The same cursor and Qt theme in both sessions and in every app.
    XCURSOR_THEME = theme.cursor.name;
    XCURSOR_SIZE = toString theme.cursor.size;
    # qt6ct answers to this name too, so it covers Qt 5 and Qt 6 apps.
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # Text login screen (greetd with tuigreet). It needs no GPU acceleration,
  # so a compositor that fails to start can never lock you out: pick the
  # other session instead. F3 opens the session list.
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      user = "greeter";
      command = lib.escapeShellArgs [
        (lib.getExe pkgs.tuigreet)
        "--time"
        "--remember"
        "--remember-user-session"
        "--asterisks"
        "--greeting"
        "Welcome to ${config.networking.hostName}"
        "--sessions"
        "${sessionDir}"
        "--cmd"
        sessionCommands.${cfg.defaultSession}
        "--theme"
        "border=magenta;text=white;prompt=magenta;time=blue;action=blue;button=magenta;container=black;input=white"
      ];
    };
  };

  # The text consoles and the login screen use the theme palette. Order:
  # black, red, green, yellow, blue, magenta, cyan, white, then the bright
  # versions. Color 0 is the background and color 7 the text.
  console.colors =
    with theme.palette;
    map (lib.removePrefix "#") [
      base
      red
      green
      yellow
      blue
      pink
      teal
      text
      surface2
      red
      green
      yellow
      blue
      pink
      teal
      subtext0
    ];
}
