# Steam and gaming tools.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.gaming;
in
{
  options.my.gaming = {
    enable = lib.mkEnableOption "Steam with Proton-GE, gamemode, gamescope, MangoHud and protontricks";

    steamDisableGpuCompositing = lib.mkEnableOption ''
      Steam's -cef-disable-gpu-compositing argument, the known workaround for
      a black Steam window under xwayland-satellite (niri). Only turn it on if
      the Steam window is black
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      # NOTE: on some systems the Steam window is completely black under
      # xwayland-satellite, which is how niri runs X11 apps. The known
      # workaround is Steam's -cef-disable-gpu-compositing argument (the same
      # as turning off GPU accelerated rendering in web views in Steam's
      # settings). It is only applied when my.gaming.steamDisableGpuCompositing
      # is set in the host file.
      package = lib.mkIf cfg.steamDisableGpuCompositing (
        pkgs.steam.override { extraArgs = "-cef-disable-gpu-compositing"; }
      );

      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      protontricks.enable = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
    environment.systemPackages = [ pkgs.mangohud ];

    # Controllers. Steam's own udev rules (programs.steam turns these on too)
    # cover Valve hardware and many pads; game-devices-udev-rules adds rules
    # for common PlayStation, Xbox, Nintendo and 8BitDo controllers and more.
    # Those rules need the uinput module.
    hardware.steam-hardware.enable = true;
    hardware.uinput.enable = true;
    services.udev.packages = [ pkgs.game-devices-udev-rules ];

    # gamemode's polkit rules let this group change the CPU governor.
    users.users.${config.my.user.name}.extraGroups = [ "gamemode" ];

    my.unfreePackages = [
      "steam"
      "steam-unwrapped"
      "steam-run"
    ];
  };
}
