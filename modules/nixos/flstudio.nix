# FL Studio under Wine, with WineASIO for low-latency audio through PipeWire.
#
# Nix installs only what FL Studio runs on: Wine, WineASIO and the `flstudio`
# launcher (plus a desktop entry). FL Studio itself is installed by hand into
# its own Wine prefix, because Image-Line's installer URLs change with every
# release and FL updates itself inside the prefix anyway.
#
# Nothing here changes system audio. Wine is not added to PATH, PipeWire's
# settings are untouched, and the JACK library and lower latency are given to
# the FL Studio process only (see the launcher below).
#
# Setup on a new machine, once:
#   1. Download the installer from https://www.image-line.com/fl-studio-download/
#   2. flstudio install ~/Downloads/flstudio_win64_*.exe
#   3. flstudio, then sign in with the Image-Line account to unlock it
#   4. In FL: Options > Audio settings > Device: WineASIO
#
# Plugin installers and other Windows tools run in the same prefix with
# `flstudio wine <program.exe>` (e.g. `flstudio wine winecfg`).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.flstudio;

  # The development branch of Wine (from nixpkgs-unstable, see flake.nix).
  # FL Studio 26.1.4 and later refuses to start on Wine before 11.21 with "The
  # validity of the program could not be verified": its signature lists its
  # attributes out of DER order, and older Wine sorted them before checking
  # the signature (https://bugs.winehq.org/show_bug.cgi?id=60273). Stable Wine
  # can replace this once a stable release (12.0) has the fix.
  wine = pkgs.wineWow64Packages.unstable;

  # WineASIO, built against the same Wine.
  wineasio = pkgs.wineasio.override {
    wineWow64Packages = pkgs.wineWow64Packages // {
      stable = wine;
    };
  };

  # nixpkgs ships the driver as wineasio64.dll, but the DLL calls itself
  # wineasio.dll, and Wine looks up builtin DLLs by that internal name. Offer
  # it under both names, in the layout WINEDLLPATH expects.
  wineasioDlls = pkgs.runCommand "wineasio-dlls" { } ''
    mkdir -p $out/x86_64-windows $out/x86_64-unix
    for name in wineasio wineasio64; do
      ln -s ${wineasio}/lib/wine/x86_64-windows/wineasio64.dll $out/x86_64-windows/$name.dll
      ln -s ${wineasio}/lib/wine/x86_64-unix/wineasio64.dll.so $out/x86_64-unix/$name.dll.so
    done
  '';

  flstudio = pkgs.writeShellApplication {
    name = "flstudio";
    runtimeInputs = [
      wine
      pkgs.libnotify
    ];
    text = ''
      export WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/flstudio"
      # Where Wine finds wineasio64.dll and its Linux half.
      export WINEDLLPATH="${wineasioDlls}"
      # WineASIO loads libjack at run time. PipeWire's own JACK library makes
      # it talk to the running PipeWire, for this process only.
      export LD_LIBRARY_PATH="${config.services.pipewire.package.jack}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export WINEDEBUG="''${WINEDEBUG:--all}"

      # Registers WineASIO in the prefix once, creating the prefix if needed.
      # The overrides skip Wine's offer to download Mono (.NET) and Gecko
      # (HTML) while the prefix is created; FL Studio needs neither.
      setup_prefix() {
        if [ ! -e "$WINEPREFIX/.wineasio-registered" ]; then
          mkdir -p "$WINEPREFIX"
          WINEDLLOVERRIDES="mscoree,mshtml=" wine regsvr32 /s wineasio64.dll
          touch "$WINEPREFIX/.wineasio-registered"
        fi
      }

      case "''${1:-}" in
        install)
          if [ $# -ne 2 ] || [ ! -f "$2" ]; then
            echo "usage: flstudio install <path to the FL Studio installer .exe>" >&2
            exit 1
          fi
          setup_prefix
          exec wine "$2"
          ;;
        wine)
          shift
          setup_prefix
          exec wine "$@"
          ;;
      esac

      # The install folder is named after the release ("FL Studio 2025"), so
      # take the newest one.
      exe=$(find "$WINEPREFIX/drive_c/Program Files/Image-Line" -maxdepth 2 \
        -name FL64.exe 2>/dev/null | sort -V | tail -n 1 || true)

      if [ -z "$exe" ]; then
        msg="FL Studio is not installed yet. Download the installer from image-line.com and run: flstudio install <installer.exe>"
        echo "$msg" >&2
        notify-send --app-name="FL Studio" "FL Studio is not installed" "$msg" || true
        exit 1
      fi

      setup_prefix
      # About 5 ms of latency, asked for by FL Studio only. Other apps keep
      # PipeWire's defaults once FL Studio is closed.
      export PIPEWIRE_LATENCY="''${PIPEWIRE_LATENCY:-256/48000}"
      exec wine "$exe" "$@"
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "flstudio";
    desktopName = "FL Studio";
    genericName = "Digital audio workstation";
    exec = "flstudio";
    icon = "audio-x-generic";
    categories = [
      "AudioVideo"
      "Audio"
    ];
    startupWMClass = "fl64.exe";
  };
in
{
  options.my.flstudio.enable = lib.mkEnableOption "the FL Studio launcher with Wine and WineASIO (FL Studio itself is installed by hand)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      flstudio
      desktopItem
    ];
  };
}
