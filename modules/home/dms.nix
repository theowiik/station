# DankMaterialShell user settings: colors, fonts and wallpaper from my.theme.
#
# DMS keeps its settings in ~/.config/DankMaterialShell/settings.json and
# ~/.local/state/DankMaterialShell/session.json and rewrites those files
# whenever something is changed in its settings window. A read-only file from
# the Nix store would break that, so instead every Home Manager activation
# (every rebuild and every boot) merges the keys below into those files.
# These keys always follow this repo; every other DMS setting stays editable
# in DMS itself.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  theme = osConfig.my.theme;
  p = theme.palette;
  accent = p.${theme.accent};

  # Mix two #rrggbb colors: `mix a b 0.3` is 30 % of a and 70 % of b.
  channels =
    hex:
    map (i: lib.fromHexString (builtins.substring i 2 (lib.removePrefix "#" hex))) [
      0
      2
      4
    ];
  toHex2 = n: lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString n));
  mix =
    a: b: t:
    "#"
    + lib.concatStrings (
      lib.zipListsWith (x: y: toHex2 (builtins.floor (x * t + y * (1 - t) + 0.5))) (channels a) (
        channels b
      )
    );

  json = name: value: pkgs.writeText name (builtins.toJSON value);

  # A DMS color theme built from the palette, in the DMS custom theme format.
  dmsTheme = json "dms-theme.json" {
    inherit (theme) name;
    dark = {
      primary = accent;
      primaryText = p.crust;
      primaryContainer = mix accent p.base 0.3;
      secondary = p.lavender;
      surface = p.mantle;
      surfaceText = p.text;
      surfaceVariant = p.surface0;
      surfaceVariantText = p.subtext0;
      surfaceTint = accent;
      background = p.crust;
      backgroundText = p.text;
      outline = p.overlay0;
      outlineVariant = p.surface2;
      surfaceContainer = p.base;
      surfaceContainerHigh = p.surface0;
      surfaceContainerHighest = p.surface1;
      error = p.red;
      warning = p.peach;
      info = p.sapphire;
      success = p.green;
    };
  };

  settings = json "dms-settings.json" {
    currentThemeName = "custom";
    currentThemeCategory = "custom";
    customThemeFile = "${dmsTheme}";
    fontFamily = theme.fonts.sans.name;
    monoFontFamily = theme.fonts.mono.name;
    # GTK and Qt apps are themed by Home Manager (modules/home/theme.nix).
    gtkThemingEnabled = false;
    qtThemingEnabled = false;

    # Idle (in seconds, 0 = never): turn the monitors off after 30 minutes,
    # any input wakes them. Never lock or suspend on its own.
    acMonitorTimeout = 1800;
    acLockTimeout = 0;
    acSuspendTimeout = 0;
  };

  session = json "dms-session.json" {
    wallpaperPath = "${theme.wallpaper}";
    isLightMode = false;
  };

  # Merge the keys of $2 into the JSON file $1, or create $1 from $2.
  mergeJson = pkgs.writeShellScript "merge-json" ''
    set -euo pipefail
    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.jq
      ]
    }
    target="$1"
    overrides="$2"
    mkdir -p "$(dirname "$target")"
    if [ -s "$target" ] && jq -e 'type == "object"' "$target" > /dev/null 2>&1; then
      tmp="$(mktemp "$target.XXXXXX")"
      jq -s '.[0] * .[1]' "$target" "$overrides" > "$tmp"
      chmod 0644 "$tmp"
      mv -f "$tmp" "$target"
    else
      install -m 0644 "$overrides" "$target"
    fi
  '';
in
lib.mkIf osConfig.my.desktop.enable {
  home.activation.dmsSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${mergeJson} "${config.xdg.configHome}/DankMaterialShell/settings.json" ${settings}
    run ${mergeJson} "${config.xdg.stateHome}/DankMaterialShell/session.json" ${session}
  '';
}
