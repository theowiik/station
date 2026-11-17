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
}
