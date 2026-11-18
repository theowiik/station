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

    niri.outputs = mkOption {
      type = types.lines;
      default = "";
      example = ''
        output "DP-1" {
            mode "2560x1440@164.958"
            position x=0 y=0
        }
      '';
      description = ''
        niri output blocks (KDL): mode, position and on/off of each monitor.
        Empty means niri detects the monitors and places them left to right
        by itself. Names come from `niri msg outputs`.
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
    };
  };
}
