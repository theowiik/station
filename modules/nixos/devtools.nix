# Command line development tools. This is the switch; the tools and their
# configuration are in modules/home/devtools.nix (Home Manager). Docker is
# here because it is a system service, nix-ld because it is system-wide.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.devtools.enable = lib.mkEnableOption "command line development tools (git, neovim, search and Nix tools, Docker, nix-ld)";

  config = lib.mkIf config.my.devtools.enable {
    # Unfree tools installed by modules/home/devtools.nix. Home Manager uses the
    # system pkgs (useGlobalPkgs), so they are allowed here.
    my.unfreePackages = [ "claude-code" ];

    # Docker, with the compose and buildx plugins (`docker compose`). The
    # daemon starts on first use through its socket instead of at boot, and
    # prunes unused images and stopped containers once a week.
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
      autoPrune.enable = true;
    };

    # Lets the main user run docker without sudo. Membership in this group is
    # effectively root access. Takes effect after logging out and back in.
    users.users.${config.my.user.name}.extraGroups = [ "docker" ];

    # Lets prebuilt Linux binaries run, such as the Godot that mise downloads.
    # NixOS has no /lib64/ld-linux-x86-64.so.2 and no /usr/lib, so these
    # binaries fail with "Could not start dynamically linked executable".
    # nix-ld puts a loader at that path that finds the libraries below. A
    # binary that still fails names the missing .so; add its package here.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # libstdc++
        zlib
        # Graphics: Vulkan and OpenGL, Wayland and X11.
        vulkan-loader
        libGL
        wayland
        libxkbcommon
        libx11
        libxcursor
        libxext
        libxi
        libxinerama
        libxrandr
        libxrender
        # Sound, fonts, input devices and desktop integration.
        alsa-lib
        libpulseaudio
        fontconfig
        freetype
        udev
        dbus
      ];
    };

    # GPU access in containers (`docker run --device nvidia.com/gpu=all ...`)
    # on hosts with the NVIDIA driver.
    hardware.nvidia-container-toolkit.enable = config.my.nvidia.enable;
  };
}
