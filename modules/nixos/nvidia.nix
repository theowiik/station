# Proprietary NVIDIA driver for Turing and newer GPUs, for Wayland.
#
# Based on the NixOS wiki NVIDIA page and the Hyprland wiki NVIDIA page
# (Hyprland 0.55), checked for this repo in November 2026.
{ config, lib, ... }:
let
  cfg = config.my.nvidia;
in
{
  options.my.nvidia = {
    enable = lib.mkEnableOption "the proprietary NVIDIA driver";

    powerManagement = lib.mkEnableOption ''
      NVIDIA suspend support: the driver saves video memory before suspend
      and restores it on resume (hardware.nvidia.powerManagement). Leave it
      off until suspend has been tested on the machine
    '';
  };

  config = lib.mkIf cfg.enable {
    # Selects the NVIDIA driver. No X server is enabled by this repo.
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      # 32-bit libraries for Steam, Proton and Wine.
      enable32Bit = true;
    };

    hardware.nvidia = {
      # The highest stable driver branch in nixpkgs (595 in NixOS 26.05).
      branch = "stable";

      # Open kernel modules. NVIDIA recommends them for Turing and newer, the
      # NixOS wiki prefers them for those GPUs, and the Hyprland wiki says
      # NVIDIA recommends them for Turing and Ampere. The RTX 3070 is Ampere
      # (GA104). Since driver 560 this must be set explicitly.
      open = true;

      # Kernel mode setting, required by Wayland compositors. It is the
      # default for driver 535 and newer and is set here to make that visible.
      # With driver 545 and newer it also turns on nvidia-drm.fbdev.
      modesetting.enable = true;

      # TODO(suspend): see my.nvidia.powerManagement in the host file.
      powerManagement.enable = cfg.powerManagement;

      nvidiaSettings = true;
    };

    # The NixOS NVIDIA module loads these only when the X server is enabled.
    # This setup is Wayland only, and the compositors need nvidia_drm.
    boot.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
    ];

    # The environment variables from the Hyprland NVIDIA wiki that are not
    # Hyprland specific, set for every session and every app. The Electron
    # one is NIXOS_OZONE_WL in modules/nixos/desktop/sessions.nix, which is
    # what that wiki recommends on NixOS.
    environment.sessionVariables = {
      # Video decoding (VA-API) through nvidia-vaapi-driver, which the NixOS
      # module installs (hardware.nvidia.videoAcceleration is on by default).
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      # Use the NVIDIA GLX library (X11 apps through Xwayland).
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    # Niri wiki, "Nvidia": the driver keeps freed buffers in its pool, so niri
    # can use close to 1 GiB of VRAM instead of about 100 MiB. This
    # application profile is the documented fix.
    environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
      builtins.toJSON {
        rules = [
          {
            pattern = {
              feature = "procname";
              matches = "niri";
            };
            profile = "Limit Free Buffer Pool On Wayland Compositors";
          }
        ];
        profiles = [
          {
            name = "Limit Free Buffer Pool On Wayland Compositors";
            settings = [
              {
                key = "GLVidHeapReuseRatio";
                value = 0;
              }
            ];
          }
        ];
      };

    my.unfreePackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];
  };
}
