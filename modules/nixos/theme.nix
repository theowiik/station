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
      default = "Catppuccin Mocha";
      description = "Name of the theme.";
    };

    palette = mkOption {
      type = types.attrsOf types.str;
      description = "Named colors as #rrggbb.";
      # Catppuccin Mocha, https://catppuccin.com/palette
      default = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };

    accent = mkOption {
      type = types.str;
      default = "mauve";
      description = "Name of the palette color used as the accent.";
    };

    fonts = {
      sans = namedPackage "Font for the user interface." {
        name = "Inter";
        package = pkgs.inter;
      };
      mono = namedPackage "Monospace font for the terminal and code." {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      size = mkOption {
        type = types.ints.positive;
        default = 11;
        description = "Font size in points.";
      };
    };

    wallpaper = mkOption {
      type = types.path;
      default = ../../wallpapers/waves.jpg;
      defaultText = lib.literalExpression "./wallpapers/waves.jpg";
      description = "Wallpaper for both sessions and the lock screens.";
    };

    cursor = {
      name = mkOption {
        type = types.str;
        default = "catppuccin-mocha-dark-cursors";
        description = "Cursor theme name.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.catppuccin-cursors.mochaDark;
        defaultText = lib.literalExpression "pkgs.catppuccin-cursors.mochaDark";
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
      # Papirus, with the folder icons recolored to match the palette.
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
    };

    gtk = namedPackage "GTK 3 theme. GTK 4 apps get the same colors from CSS." {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };
}
