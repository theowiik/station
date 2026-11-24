# station: the gaming desktop.
#
# Hardware, read from Windows on this machine (November 2026):
#   CPU       AMD Ryzen 7 9800X3D, 8 cores and 16 threads, integrated Radeon GPU
#   GPU       NVIDIA GeForce RTX 3070 (GA104, PCI ID 10de:2488), drives the monitor
#   Board     MSI MAG B650 TOMAHAWK WIFI (MS-7D75), BIOS 1.M0
#   Network   Realtek 2.5GbE, MediaTek RZ616 (MT7922) Wi-Fi 6E and Bluetooth
#   Memory    32 GB DDR5
#   Firmware  UEFI (so systemd-boot), Secure Boot currently on
#
# The disk layout, partition UUIDs and kernel modules are deliberately not
# here. They come from hardware-configuration.nix, which was generated on this
# machine at install time.
{ pkgs, ... }:
let
  # Language, regional formats, time zone and keyboard, in one place.
  locale = {
    timeZone = "Europe/Stockholm";
    language = "en_US.UTF-8"; # messages and menus
    formats = "sv_SE.UTF-8"; # dates, numbers, currency, paper size, units
    keyboardLayout = "se";
  };

  # The same nixpkgs with CUDA turned on, used only for Blender below.
  # allowUnfree is needed because CUDA and its libraries are unfree; it only
  # applies to this package set, not to the system's allowlist.
  cudaPkgs = import pkgs.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./nas.nix
  ];

  networking.hostName = "station";
  my.locale = locale;

  # Login name. Use the same name when creating the user in the installer.
  my.user.name = "theo";

  my.desktop.enable = true;
  my.desktop.defaultSession = "niri";
  my.nvidia.enable = true;
  my.gaming.enable = true;
  my.flstudio.enable = true;
  my.windowsVm.enable = true;
  my.shell.enable = true;
  my.devtools.enable = true;

  # DaVinci Resolve (the free version), here and not in the shared desktop
  # apps because it needs the NVIDIA GPU. On Linux the free version cannot
  # decode or encode H.264/H.265 or AAC audio: convert such clips first, e.g.
  # ffmpeg -i in.mp4 -c:v dnxhd -profile:v dnxhr_hq -c:a pcm_s16le out.mov
  #
  # Blender with CUDA/OptiX, so Cycles renders on the RTX 3070. It comes from a
  # separate copy of the same nixpkgs with cudaSupport on, so only Blender and
  # its dependencies are CUDA builds, not the whole system. That exact build is
  # prebuilt in the NixOS CUDA team's cache (nix.settings below); without the
  # cache it compiles locally, which takes over an hour. Right after a nixpkgs
  # update the cache can lag behind for a while.
  environment.systemPackages = [
    pkgs.davinci-resolve
    cudaPkgs.blender
  ];
  my.unfreePackages = [ "davinci-resolve" ];

  nix.settings = {
    extra-substituters = [ "https://cache.nixos-cuda.org" ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # AMD microcode, and firmware for the MT7922 Wi-Fi and Bluetooth chip and
  # the integrated GPU.
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # TODO(suspend): untested. Hibernation is off for every host
  # (modules/nixos/base.nix); suspend is still allowed. On the real machine,
  # run `systemctl suspend` and wake it up. If the screen stays black or the
  # desktop is corrupted after resume, set this to true (it turns on
  # hardware.nvidia.powerManagement, which saves video memory over suspend),
  # rebuild and test again. If suspend still fails, add
  # `systemd.sleep.settings.Sleep.AllowSuspend = "no";` here.
  my.nvidia.powerManagement = false;

  # TODO(gpu): the integrated Radeon GPU of the 9800X3D is enabled in the
  # firmware, so Linux sees two GPUs. In Windows the monitor runs on the
  # RTX 3070 and nothing uses the integrated GPU. Niri and Hyprland should
  # pick the GPU the firmware booted on. If one of them renders on the wrong
  # GPU (black screen, or very slow), look up the RTX 3070 with
  # `ls -l /dev/dri/by-path` and set the matching option below, or turn the
  # integrated GPU off in the firmware.
  # my.desktop.niri.renderDevice = "/dev/dri/renderD128";
  # my.desktop.hyprland.drmDevices = "/dev/dri/card1";

  # Monitors in niri: the BenQ stands left of the LG, bottom edges aligned.
  # The Samsung (a TV on DP-5) stays off; it is not a desk monitor.
  # Names and modes come from `niri msg outputs`.
  my.desktop.niri.outputs = ''
    output "PNP(BNQ) BenQ XL2411Z K5E04337SL0" {
        mode "1920x1080@60.000"
        position x=0 y=360
    }

    output "LG Electronics LG ULTRAGEAR 108MALF2AW84" {
        mode "2560x1440@164.958"
        position x=1920 y=0
        focus-at-startup
    }

    output "Samsung Electric Company SAMSUNG 0x01000E00" {
        off
    }
  '';

  # TODO(steam): if the Steam window is completely black in the niri session,
  # set this to true (see modules/nixos/gaming.nix).
  my.gaming.steamDisableGpuCompositing = false;

  # TODO(secure-boot): Secure Boot is on in the firmware. The NixOS installer
  # and systemd-boot are not signed, so turn Secure Boot off before installing.
  # To use NixOS with Secure Boot on later (some Windows anti-cheat games
  # require it), look at lanzaboote.

  # TODO(windows): Windows stays on its own drive and boots from the firmware
  # boot menu (F11 on MSI boards). To add it to the systemd-boot menu instead,
  # see boot.loader.systemd-boot.windows; it needs the EFI device handle of the
  # Windows drive, which can only be read on the machine.

  system.stateVersion = "26.05";
}
