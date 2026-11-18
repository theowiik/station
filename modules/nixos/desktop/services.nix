# Everyday services: sound, Bluetooth and removable drives.
{ config, lib, ... }:
lib.mkIf config.my.desktop.enable {
  # Sound: PipeWire with ALSA and PulseAudio compatibility, managed by
  # WirePlumber. pavucontrol (modules/nixos/desktop/apps.nix) is the GUI.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth. WirePlumber adds paired headphones as audio devices on its own.
  # Pairing GUI: DMS in the niri session, blueman in the Hyprland session
  # (and blueman-manager from the launcher in both).
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Lets BlueZ report the battery level of headphones.
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  # Removable drives. udisks2 does the mounting (udiskie, started by Home
  # Manager, mounts drives as soon as they are plugged in). gvfs adds trash,
  # phones (MTP) and network places to the file manager.
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # mDNS, so other machines on the LAN resolve as <hostname>.local
  # (e.g. http://xps.local:8384) and this one is reachable as station.local.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Tailscale VPN. Log in once with `sudo tailscale up`; the login is kept
  # across rebuilds. openFirewall opens its UDP port for direct connections.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # File sync between devices, running as the main user. Devices and folders
  # are added in the web UI at http://127.0.0.1:8384 and kept across rebuilds.
  services.syncthing =
    let
      home = config.users.users.${config.my.user.name}.home;
    in
    {
      enable = true;
      user = config.my.user.name;
      dataDir = home;
      configDir = "${home}/.config/syncthing";
      # 22000 TCP/UDP for sync, 21027 UDP for local discovery.
      openDefaultPorts = true;
      overrideDevices = false;
      overrideFolders = false;
    };
}
