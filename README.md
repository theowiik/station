# station

NixOS configuration for my gaming desktop.

One machine (`station`) plus a Hyper-V guest (`station-vm`) to test the
config before installing it. The structure is ready for a second real host:
everything reusable is a module under `modules/` with a `my.<name>.enable`
switch.

## What you get

| | |
|---|---|
| Base | NixOS 26.05 "Yarara" with Home Manager release-26.05, flakes only (no channels) |
| Main session | niri 26.04 from nixpkgs, with DankMaterialShell (DMS) 1.4.6 as the shell: bar, launcher, notifications, control center, lock screen, wallpaper, polkit agent |
| X11 apps | xwayland-satellite 0.8.3, started by niri on demand |
| Fallback session | Hyprland 0.55.4 from nixpkgs with Waybar, fuzzel, mako, hyprlock and swaybg |
| Login | greetd with tuigreet (text login screen, pick the session with F3) |
| GPU (station) | NVIDIA 595 driver with the open kernel modules, modesetting, 32-bit graphics |
| Gaming (station) | Steam with Remote Play and Proton-GE, gamemode, gamescope, MangoHud, protontricks, controller udev rules |
| Everyday | PipeWire (ALSA, PulseAudio, WirePlumber) with pavucontrol, Bluetooth with blueman, NetworkManager, screen sharing portals, USB automount (udiskie), Nautilus, Firefox, Discord, fonts with emoji and CJK |
| Theme | Catppuccin Mocha everywhere: DMS, foot, GTK 3 and 4, Qt 5 and 6, both compositors, the lock screens and the text console. One font pair (Inter, JetBrainsMono Nerd Font) and one wallpaper |
| Shell | zsh configured with Home Manager, no framework |
| Upkeep | weekly garbage collection and store optimisation, at most 10 boot menu entries, no hibernation |

The versions are the ones pinned by `flake.lock` (nixpkgs `nixos-26.05`).

## Layout

```
flake.nix                    inputs (nixpkgs, home-manager) and the two hosts
hosts/
  station/                   the real machine: hardware notes, NVIDIA, gaming, TODOs
  station-vm/                the Hyper-V guest
modules/
  nixos/                     NixOS modules
    base.nix                 Nix settings, garbage collection, boot loader, power
    locale.nix               my.locale: time zone, language, formats, keyboard
    user.nix                 my.user and Home Manager
    theme.nix                my.theme: palette, fonts, wallpaper, cursor, icons
    desktop/                 my.desktop: sessions, login screen, DMS, audio, Bluetooth, fonts, apps
    nvidia.nix               my.nvidia
    gaming.nix               my.gaming
    shell.nix                my.shell
    devtools.nix             my.devtools
  home/                      Home Manager modules, following the my.* switches
    niri.nix  dms.nix        niri config and DMS settings
    hyprland.nix             Hyprland, Waybar, fuzzel, mako, hyprlock
    theme.nix                GTK, Qt, cursor and icons
    terminal.nix  shell.nix  devtools.nix  desktop.nix
```

## Before you install: the TODOs

Search the repo for `TODO(` to find them all.

- `hosts/*/hardware-configuration.nix` are placeholders with fake devices, so
  the flake builds before installing. Every build prints a warning until they
  are replaced (see the install steps below).
- `TODO(secure-boot)`: Secure Boot is on in the firmware of station. Turn it
  off before booting the NixOS installer.
- `TODO(suspend)`: suspend is untested. Hibernation is off on purpose.
- `TODO(gpu)`: the CPU has an integrated GPU next to the RTX 3070. Check that
  the sessions use the RTX 3070.
- `TODO(monitor)`: no resolutions or refresh rates are set. Check that the
  monitor runs at its full refresh rate.
- `TODO(steam)`: a switch for the known black Steam window workaround.
- `TODO(windows)`: how to boot Windows (firmware boot menu for now).
- `TODO(git)`: your commit name and email.
- Secrets: see [Secrets](#secrets).

## Test in a Hyper-V VM

Hyper-V, not VirtualBox: Hyper-V is already on for WSL2 and Docker, and
VirtualBox on top of it is too slow to boot NixOS.

1. Create a VM in Hyper-V Manager (Action, New, Virtual Machine):
   - **Generation 2**.
   - Startup memory 8192 MB; dynamic memory can stay on.
   - Network: **Default Switch**.
   - A new virtual disk of 60 GB or more, and the NixOS 26.05 graphical ISO
     as the install medium.
2. Before starting it, open the VM's **Settings**:
   - Security: turn **Secure Boot off**.
   - Processor: 4 virtual processors.
3. Start it. Boot the ISO and install. Pick **No desktop** (this
   repo brings the desktop), the Swedish keyboard, and create the user with
   the name `theo` and a password. Reboot into the new system.
4. Log in on the text console and switch to this repo:

   ```sh
   nix-shell -p git
   git clone <repo-url> ~/station
   cd ~/station
   sudo nixos-generate-config --show-hardware-config > hosts/station-vm/hardware-configuration.nix
   git add hosts/station-vm/hardware-configuration.nix
   sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#station-vm
   ```

   `<repo-url>` is wherever this repo is pushed (its `origin` is
   `https://github.com/theowiik/station.git`; push it first). A flake only
   sees files that git knows about, which is why the generated file is added
   with `git add` before the rebuild. Commit it afterwards.
   If your user name differs from the one you created in the installer, set
   a password for it with `sudo passwd <name>` before rebooting.
5. Reboot. The login screen starts Hyprland by default in the VM, because
   niri may not render well in a VM. Press F3 at the login screen to try
   niri.

## Install on the real machine

NixOS goes on its own drive. Do not touch the Windows drive.

1. In the firmware (Del at power on), turn **Secure Boot off**.
2. Boot the NixOS 26.05 ISO from a USB stick (F11 opens the boot menu on MSI
   boards).
3. Install, either way:
   - **With the graphical installer**, like in the VM: pick the NixOS drive
     (check the model and size carefully), "No desktop", the Swedish keyboard
     and the user `theo`. After the reboot, log in on the text
     console and run:

     ```sh
     nix-shell -p git
     git clone <repo-url> ~/station
     cd ~/station
     sudo nixos-generate-config --show-hardware-config > hosts/station/hardware-configuration.nix
     git add hosts/station/hardware-configuration.nix
     sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#station
     ```

   - **Or with `nixos-install`**: partition the NixOS drive yourself (an EFI
     system partition of at least 1 GB, FAT32, plus a root partition), mount
     root on `/mnt` and the EFI partition on `/mnt/boot`, then:

     ```sh
     nix-shell -p git
     git clone <repo-url> /tmp/station
     cd /tmp/station
     sudo nixos-generate-config --root /mnt --show-hardware-config > hosts/station/hardware-configuration.nix
     git add hosts/station/hardware-configuration.nix
     sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake .#station
     sudo nixos-enter --root /mnt -c 'passwd <name>'
     ```

     After the first boot, clone the repo again to `~/station` and copy the
     generated `hardware-configuration.nix` into it.
4. Commit the generated `hosts/station/hardware-configuration.nix` and push
   it.
5. Reboot, log in and work through `TODO(suspend)`, `TODO(gpu)` and
   `TODO(monitor)` in `hosts/station/default.nix`.

After that, rebuild with `rebuild` (a zsh alias for
`sudo nixos-rebuild switch --flake ~/station`). Update everything with
`nix flake update`, rebuild, and commit `flake.lock`.

## Choose Niri or Hyprland at login

The login screen is tuigreet, a text login screen that works without GPU
acceleration.

1. Type the user name and press Enter.
2. Press **F3** to open the session list and pick **niri** or **Hyprland**.
3. Type the password and press Enter.

tuigreet remembers the last session per user. Before a session has been
picked, station starts niri and station-vm starts Hyprland. If a session
fails to start you land back at the login screen and can pick the other one.
F12 opens the power menu.

Main keys in **niri** (Super is the Windows key):

| Keys | Action |
|---|---|
| Super+D or Super+Space | app launcher (DMS) |
| Super+T or Super+Enter | terminal (foot) |
| Super+E | file manager |
| Super+N | notifications |
| Super+Alt+V | clipboard history |
| Super+X | power menu |
| Super+Alt+L | lock the screen |
| Ctrl+Shift+Esc | task manager |
| Super+Q | close window |
| Super+O | overview |
| Super+Shift+/ | all key bindings |
| Super+Shift+E | quit niri |

In **Hyprland**: Super+D or Super+Space launcher (fuzzel), Super+T terminal,
Super+E file manager, Super+Q close, Super+1 to 0 workspaces, Super+Shift+1
to 0 move window, Super+F maximize, Super+Shift+F fullscreen, Super+Alt+L
lock, Print screenshot of an area, Super+Shift+E quit.

## Gaming notes

- Proton-GE shows up in Steam under Properties, Compatibility, with its
  version in the name (GE-Proton11-1 in nixpkgs 26.05 at the time of
  writing).
- Steam launch options: `mangohud %command%` for the overlay,
  `gamemoderun %command%` for gamemode, or both.
- If a fullscreen game misbehaves in niri (cursor escapes, wrong size), the
  niri wiki suggests running it through gamescope:
  `gamescope -f -W <width> -H <height> --force-grab-cursor --backend sdl -- %command%`,
  with the monitor's resolution (2560 by 1440 on station, as seen in Windows).
- If the Steam window is completely black in niri, see `TODO(steam)`.

## Roll back to a previous generation

Every rebuild creates a new generation with its own entry in the boot menu
(the 10 newest are kept).

1. Reboot. The systemd-boot menu shows for 5 seconds; press an arrow key to
   stop the countdown.
2. Pick an older entry ("NixOS ... Generation N") and press Enter. This boots
   that generation once; the newest one stays the default.
3. To stay on the older system, run `sudo nixos-rebuild switch --rollback`,
   which makes the generation before the newest one the current one again.
   Or revert the change in git and rebuild.

`nixos-rebuild list-generations` lists the generations.

## Secrets

There are no secrets in this repo, and `.gitignore` blocks common key files.
User passwords are set with `passwd` and stay on the machine.

TODO: secrets management with sops-nix (for example `hashedPasswordFile` for
the user or Wi-Fi passwords). It is not set up yet.

## What was checked, and what was not

Checked in WSL2 (Ubuntu 24.04, Nix 2.32.4) on the Windows PC, from a clean
clone of this repo:

- `nix flake check` passes. It only prints the expected warnings about the
  placeholder hardware configurations.
- Both configurations build (build only, nothing was switched to):
  `nix build .#nixosConfigurations.station.config.system.build.toplevel`
  and the same for `station-vm`.
- The build also checks the generated niri config with `niri validate` and
  the Hyprland config with `Hyprland --verify-config`. Both checks were
  tried on deliberately broken files and do reject them.

This only shows that the configurations evaluate and build. Nothing has run
yet: the display, the NVIDIA driver, both sessions, DMS, audio, Bluetooth,
networking, screen sharing, Steam, controllers and suspend are all untested,
both in the VM and on the real machine.
