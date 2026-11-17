# The graphical desktop.
#
# Niri with DankMaterialShell is the main session. Hyprland with Waybar is a
# small fallback session that can be picked at the login screen if niri has
# problems.
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./sessions.nix
    ./services.nix
    ./fonts.nix
    ./apps.nix
  ];

  options.my.desktop = {
    enable = lib.mkEnableOption "the graphical desktop (niri and Hyprland sessions)";

    defaultSession = mkOption {
      type = types.enum [
        "niri"
        "hyprland"
      ];
      default = "niri";
      description = ''
        Session the login screen starts until the user picks another one.
        The login screen then remembers the last session per user.
      '';
    };

    niri.renderDevice = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/dev/dri/renderD129";
      description = ''
        DRM render node that niri renders on. null lets niri pick the primary
        GPU. Only needed if niri picks the wrong GPU on a machine with more
        than one.
      '';
    };

    hyprland = {
      drmDevices = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/dev/dri/card1";
        description = ''
          Value for AQ_DRM_DEVICES: the GPUs Hyprland may use, primary first,
          separated by colons. null lets Hyprland pick.
        '';
      };

      softwareCursor = lib.mkEnableOption ''
        a software cursor in Hyprland. Useful in virtual machines, where the
        hardware cursor is often invisible
      '';
    };
  };
}
