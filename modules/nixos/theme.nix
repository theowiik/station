# One dark theme for everything: the desktop shell, the terminal, GTK and Qt
# apps, both compositors, the lock screens and the text login screen.
#
# This module only holds the values. The desktop modules (NixOS and Home
# Manager) read them from config.my.theme.
{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;

  # Something with a name that comes from a package: a font family, an icon
  # theme, a GTK theme. Each field has its own default, so a host can
  # override one of them alone.
  namedPackage =
    description: defaults:
    mkOption {
      inherit description;
      default = { };
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = defaults.name;
            description = "Name the programs look for.";
          };
          package = mkOption {
            type = types.package;
            default = defaults.package;
            defaultText = lib.literalMD "see `modules/nixos/theme.nix`";
            description = "Package that provides it.";
          };
        };
      };
    };
in
{
  options.my.theme = {
    name = mkOption {
      type = types.str;
      default = "Graphite";
      description = "Name of the theme.";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      description = "Named colors as #rrggbb.";
      # Graphite: neutral greys with GitHub-dark colors, and a cornflower blue
      # accent. The keys are Catppuccin's role names (base, surface0, text,
      # mauve, ...) because the modules use them; the values are not
      # Catppuccin. From darkest to lightest: crust, mantle, base, surface0-2,
      # overlay0-2, subtext0-1, text.
      default = {
        rosewater = "#ffdcd7";
        flamingo = "#ffa198";
        pink = "#f778ba";
        mauve = "#bc8cff";
        red = "#f85149";
        maroon = "#ff7b72";
        peach = "#f0883e";
        yellow = "#d29922";
        green = "#3fb950";
        teal = "#39c5cf";
        sky = "#56d4dd";
        sapphire = "#6cb6ff";
        blue = "#58a6ff";
        cornflower = "#4c8dff";
        lavender = "#79c0ff";
        text = "#e6edf3";
        subtext1 = "#c1c9d1";
        subtext0 = "#9da5ae";
        overlay2 = "#848d97";
        overlay1 = "#6e7681";
        overlay0 = "#5c636c";
        surface2 = "#3a3a3a";
        surface1 = "#2e2e2e";
        surface0 = "#232323";
        base = "#161616";
        mantle = "#111111";
        crust = "#0b0b0b";
      };
    };

    accent = mkOption {
      type = types.str;
      default = "cornflower";
      description = "Name of the palette color used as the accent.";
    };

    fonts = {
      sans = namedPackage "Font for the user interface." {
        name = "Inter";
        package = pkgs.inter;
      };
      mono = namedPackage "Monospace font for the terminal and code." {
        name = "Iosevka Nerd Font";
        package = pkgs.nerd-fonts.iosevka;
      };
      size = mkOption {
        type = types.ints.positive;
        default = 11;
        description = "Font size in points.";
      };
    };

    wallpaper = mkOption {
      type = types.path;
      default = ../../wallpapers/dark-turns.jpg;
      defaultText = lib.literalExpression "./wallpapers/dark-turns.jpg";
      description = "Wallpaper for both sessions and the lock screens.";
    };

    cursor = {
      name = mkOption {
        type = types.str;
        # Black with a white outline, neutral like the palette.
        default = "Bibata-Modern-Classic";
        description = "Cursor theme name.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.bibata-cursors;
        defaultText = lib.literalExpression "pkgs.bibata-cursors";
        description = "Package that provides the cursor theme.";
      };
      size = mkOption {
        type = types.ints.positive;
        default = 24;
        description = "Cursor size in pixels.";
      };
    };

    icons = namedPackage "Icon theme." {
      name = "Papirus-Dark";
      # Papirus, with blue folder icons, the closest of its colors to the
      # cornflower accent.
      package = pkgs.papirus-icon-theme.override { color = "blue"; };
    };

    gtk = namedPackage "GTK 3 theme. GTK 4 apps get the same colors from CSS." {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };
}
