# A Windows 11 virtual machine with KVM, QEMU and libvirt, managed in
# virt-manager.
#
# Nix installs the hypervisor, TPM 2.0 emulation (swtpm) and UEFI firmware
# that Windows 11 needs, plus the VirtIO drivers as an ISO. The VM itself is
# created by hand in virt-manager, because its disk image and settings are
# state that lives in /var/lib/libvirt, not in this repo.
#
# The GPU is not passed through. The RTX 3070 drives the monitors and the
# games here, and VFIO passthrough would take it away from Linux completely.
# The VM is therefore fast for desktop work and slow for games and 3D.
#
# Creating the VM, once:
#   1. Download the Windows 11 ISO from https://www.microsoft.com/software-download/windows11
#   2. virt-manager > File > New Virtual Machine > Local install media, pick
#      the ISO. Give it 8 to 16 GB of RAM and 8 CPUs, and a disk of 80 GB or
#      more. Tick "Customize configuration before install".
#   3. In the customize window:
#        Overview  Firmware: UEFI (the secboot one). A TPM 2.0 is added
#                  automatically for Windows 11.
#        CPUs      "Copy host CPU configuration" (host-passthrough). Under
#                  Topology, set 1 socket, 4 cores, 2 threads for 8 CPUs.
#        SATA Disk 1  change the bus to VirtIO.
#        NIC       change the device model to virtio.
#        Add Hardware > Storage > CD-ROM, with the ISO at
#                  /run/current-system/sw/share/virtio-win/virtio-win.iso
#   4. Begin installation. Windows sees no disk at first: click Load driver
#      and pick the virtio CD's viostor\w11\amd64 folder.
#   5. After Windows is installed, run virtio-win-guest-tools.exe from the
#      virtio CD. It installs the remaining drivers and the SPICE agent
#      (shared clipboard, window resizing).
#
# Smooth display over Remote Desktop, set up once in Windows:
#   1. Give the account a password (RDP refuses accounts without one).
#   2. Settings > System > Remote Desktop: On.
#   3. In an admin terminal, allow 60 fps and H.264 4:4:4 (Windows defaults
#      to 30 fps), then restart Windows:
#        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v DWMFRAMEINTERVAL /t REG_DWORD /d 15 /f
#        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v AVC444ModePreferred /t REG_DWORD /d 1 /f
# After that, `win11` (or "Windows 11" in the app launcher) starts the VM and
# connects.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.windowsVm;

  # nixpkgs ships the VirtIO drivers as a folder, but the Windows installer
  # needs them on a CD to load the disk driver, so pack them into an ISO.
  virtioWinIso = pkgs.runCommand "virtio-win-iso" { nativeBuildInputs = [ pkgs.xorriso ]; } ''
    mkdir -p $out/share/virtio-win
    xorriso -as mkisofs -quiet -J -R -V VIRTIO-WIN \
      -o $out/share/virtio-win/virtio-win.iso ${pkgs.virtio-win}
  '';

  # `win11`: starts the VM if it is off and connects over Remote Desktop.
  # RDP with H.264 is much smoother than the SPICE display in virt-manager,
  # which tops out around 30 fps. The SDL client asks for the Windows password
  # in its own dialog, so the desktop entry works without a terminal.
  win11 = pkgs.writeShellApplication {
    name = "win11";
    runtimeInputs = [
      config.virtualisation.libvirtd.package
      pkgs.freerdp
      pkgs.libnotify
      pkgs.netcat
    ];
    text = ''
      vm=win11
      virsh() { command virsh -c qemu:///system "$@"; }

      fail() {
        echo "$2" >&2
        notify-send --app-name="Windows 11" "$1" "$2" || true
        exit 1
      }

      # The VM is state in /var/lib/libvirt, not part of this config, so a
      # fresh machine has the tools but no Windows yet.
      if ! virsh dominfo "$vm" >/dev/null 2>&1; then
        fail "Windows 11 is not installed" \
          "There is no '$vm' VM on this computer. Create it first; the steps are at the top of modules/nixos/windows-vm.nix."
      fi

      if [ "$(virsh domstate "$vm")" != running ]; then
        virsh start "$vm" >/dev/null
      fi

      # Wait for the VM's address, then for Windows to accept RDP.
      ip=""
      for _ in $(seq 1 90); do
        ip=$(virsh domifaddr "$vm" | awk '/ipv4/ { sub(/\/.*/, "", $4); print $4; exit }')
        if [ -n "$ip" ] && nc -z -w 1 "$ip" 3389; then
          break
        fi
        ip=""
        sleep 1
      done
      if [ -z "$ip" ]; then
        fail "Could not connect" \
          "Windows did not answer on Remote Desktop. Is Remote Desktop turned on in Windows?"
      fi

      exec sdl-freerdp /v:"$ip" /u:${config.my.user.name} /cert:tofu \
        /f /gfx:AVC444 /network:lan /dynamic-resolution \
        +clipboard /sound /microphone "$@"
    '';
  };

  win11Desktop = pkgs.makeDesktopItem {
    name = "win11";
    desktopName = "Windows 11";
    comment = "Start the Windows 11 VM and connect with Remote Desktop";
    exec = "win11";
    icon = "computer";
    categories = [
      "System"
      "Emulator"
    ];
  };
in
{
  options.my.windowsVm.enable = lib.mkEnableOption "KVM/QEMU with libvirt and virt-manager, set up for a Windows 11 VM";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      # Emulated TPM 2.0, which Windows 11 requires. UEFI (OVMF) firmware
      # with Secure Boot comes with QEMU.
      qemu.swtpm.enable = true;
    };

    programs.virt-manager.enable = true;

    # Hand USB devices (a game controller, a USB stick) to the VM from the
    # virt-manager window.
    virtualisation.spiceUSBRedirection.enable = true;

    # Manage system VMs without a password prompt.
    users.users.${config.my.user.name}.extraGroups = [ "libvirtd" ];

    environment.systemPackages = [
      virtioWinIso
      win11
      win11Desktop
    ];
    # Not linked into /run/current-system/sw by default.
    environment.pathsToLink = [ "/share/virtio-win" ];
  };
}
