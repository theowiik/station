# station

My NixOS config for my own gaming desktop. It's not a general-purpose
template. The hardware, monitors, user name (`theo`), keyboard layout and app
picks are all for this one machine and the way I use it. Feel free to borrow
pieces, but don't expect it to work on other hardware as is.

The machine is `station`: Ryzen 7 9800X3D, RTX 3070, with NixOS on its own
drive next to Windows.

## Everyday use

| Command | What it does |
|---|---|
| `rebuild` | apply changes from `~/station` (`sudo nixos-rebuild switch --flake ~/station`) |
| `update` | update every flake input (`flake.lock`), then rebuild. Commit `flake.lock` afterwards |
| `stn-help` | list the aliases |
| `niri-help [word]` | list niri keybinds, optionally filtered |

A flake only sees files git knows about, so `git add` new files before
rebuilding.

## What's in it

| | |
|---|---|
| Base | NixOS 26.05 with Home Manager, flakes only (no channels). A few fast-moving tools come from nixos-unstable (see `flake.nix`) |
| Desktop | niri with DankMaterialShell (bar, launcher, notifications, lock screen). Hyprland with Waybar and fuzzel as the fallback session. Login with greetd and tuigreet |
| GPU | NVIDIA 595 driver with the open kernel modules |
| Gaming | Steam with Proton-GE, gamemode, gamescope, MangoHud, protontricks, controller rules |
| Apps | Helium, Bitwarden, Discord, Signal, Spotify, Krita, Inkscape, Nautilus, Ghostty, DaVinci Resolve, Blender |
| Services | PipeWire, Bluetooth, NetworkManager, Tailscale, Syncthing, Avahi (`station.local`), USB automount, screen sharing portals, Synology shares in `/mnt/syno` |
| Dev tools | zsh, git, gh, neovim, mise, uv, ripgrep, fd, jq, Docker, nix-ld (for prebuilt binaries like mise's Godot), Claude Code, Codex, T3 Code |
| Theme | Graphite (neutral greys, cornflower blue accent) everywhere, Bibata cursor, Papirus icons, Inter and JetBrainsMono Nerd Font, `wallpapers/dark-turns.jpg` |
| Upkeep | weekly garbage collection and store optimisation, 10 boot menu entries kept |

## Layout

```
flake.nix                 inputs and the station host
hosts/
  station/                the desktop: monitors, NVIDIA, gaming, TODOs
modules/
  nixos/                  system modules, each behind a my.<name>.enable switch
    base.nix              Nix settings, garbage collection, boot loader
    locale.nix            time zone, language, keyboard
    user.nix              the user and Home Manager
    theme.nix             palette, fonts, wallpaper, cursor, icons
    desktop/              sessions, login, services, apps
    nvidia.nix  gaming.nix  shell.nix  devtools.nix
  home/                   Home Manager modules, following the same switches
    niri.nix  dms.nix     niri config and DMS settings
    hyprland.nix          Hyprland, Waybar, fuzzel, mako, hyprlock
    theme.nix             GTK, Qt, cursor and icons
    terminal.nix  shell.nix  devtools.nix  desktop.nix
pkgs/helium.nix           Helium browser, wrapping the official AppImage
wallpapers/
```

## Sessions and keys

At the tuigreet login screen, press **F3** to choose niri or Hyprland. It
remembers the last choice. F12 opens the power menu. If a session fails,
you land back at the login screen.

niri (Super is the Windows key):

| Keys | Action |
|---|---|
| Super+D / Super+Space | app launcher |
| Super+T / Super+Enter | terminal |
| Super+E | file manager |
| Super+N | notifications |
| Super+Alt+V | clipboard history |
| Super+X | power menu |
| Super+Alt+L | lock |
| Ctrl+Shift+Esc | task manager |
| Super+Q | close window |
| Super+O | overview |
| Print | screenshot |
| Super+Shift+/ | all keybinds |
| Super+Shift+E | quit niri |

Hyprland: Super+D launcher, Super+T terminal, Super+E files, Super+Q close,
Super+1–0 workspaces, Super+Shift+1–0 move window, Super+F maximize,
Super+Shift+F fullscreen, Super+Alt+L lock, Print area screenshot,
Super+Shift+E quit.

## Gaming notes

- Proton-GE is under Steam, Properties, Compatibility.
- Launch options: `mangohud %command%`, `gamemoderun %command%`, or both.
- If a fullscreen game misbehaves in niri (cursor escapes, wrong size), run it
  through gamescope:
  `gamescope -f -W 2560 -H 1440 --force-grab-cursor --backend sdl -- %command%`.
- If the Steam window is completely black in niri, see `TODO(steam)`.

## Rolling back

Every rebuild adds a boot menu entry. To go back, reboot, press an arrow key
in the systemd-boot menu and pick an older generation. That boots it once.
To make it stick, run `sudo nixos-rebuild switch --rollback`, or revert the
change in git and rebuild.

## Open TODOs

Run `grep -rn 'TODO(' .` to find them in the code.

- `TODO(suspend)`: suspend is untested. Hibernation is off on purpose.
- `TODO(gpu)`: check that the sessions run on the RTX 3070, not the iGPU.
- `TODO(steam)`: a switch for the black Steam window workaround.
- `TODO(windows)`: Windows boots from the firmware boot menu (F11) for now.
- `TODO(git)`: commit name and email aren't set in the config.
- Secrets management (sops-nix) isn't set up. There are no secrets in the
  repo. Passwords are set with `passwd` and stay on the machine.

## Reinstalling

NixOS goes on its own drive. Leave the Windows drive alone. Secure Boot must
be off in the firmware (Del at power on).

1. Boot the NixOS 26.05 ISO (F11 for the boot menu). Install with "No
   desktop", the Swedish keyboard and the user `theo`.
2. Log in on the text console and run:

   ```sh
   nix-shell -p git
   git clone https://github.com/theowiik/station.git ~/station
   cd ~/station
   sudo nixos-generate-config --show-hardware-config > hosts/station/hardware-configuration.nix
   git add hosts/station/hardware-configuration.nix
   sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#station
   ```

3. Commit the new `hardware-configuration.nix` if it changed, then reboot.

