# GTK, Qt, cursor and icons from my.theme, so apps match the shell and the
# terminal.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  theme = osConfig.my.theme;
  p = theme.palette;
  accent = p.${theme.accent};

  # Colors for adw-gtk3 (GTK 3) and libadwaita (GTK 4). Both read these
  # named colors from the user CSS.
  gtkCss = ''
    /* ${theme.name}, generated from my.theme by modules/home/theme.nix. */
    @define-color accent_color ${accent};
    @define-color accent_bg_color ${accent};
    @define-color accent_fg_color ${p.crust};
    @define-color destructive_color ${p.red};
    @define-color destructive_bg_color ${p.red};
    @define-color destructive_fg_color ${p.crust};
    @define-color success_color ${p.green};
    @define-color success_bg_color ${p.green};
    @define-color success_fg_color ${p.crust};
    @define-color warning_color ${p.peach};
    @define-color warning_bg_color ${p.peach};
    @define-color warning_fg_color ${p.crust};
    @define-color error_color ${p.red};
    @define-color error_bg_color ${p.red};
    @define-color error_fg_color ${p.crust};
    @define-color window_bg_color ${p.base};
    @define-color window_fg_color ${p.text};
    @define-color view_bg_color ${p.base};
    @define-color view_fg_color ${p.text};
    @define-color headerbar_bg_color ${p.mantle};
    @define-color headerbar_fg_color ${p.text};
    @define-color headerbar_border_color ${p.text};
    @define-color headerbar_backdrop_color ${p.base};
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);
    @define-color sidebar_bg_color ${p.mantle};
    @define-color sidebar_fg_color ${p.text};
    @define-color sidebar_backdrop_color ${p.mantle};
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color secondary_sidebar_bg_color ${p.mantle};
    @define-color secondary_sidebar_fg_color ${p.text};
    @define-color secondary_sidebar_backdrop_color ${p.mantle};
    @define-color secondary_sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color card_bg_color ${p.surface0};
    @define-color card_fg_color ${p.text};
    @define-color card_shade_color rgba(0, 0, 0, 0.36);
    @define-color dialog_bg_color ${p.base};
    @define-color dialog_fg_color ${p.text};
    @define-color popover_bg_color ${p.mantle};
    @define-color popover_fg_color ${p.text};
    @define-color popover_shade_color rgba(0, 0, 0, 0.25);
    @define-color thumbnail_bg_color ${p.surface0};
    @define-color thumbnail_fg_color ${p.text};
    @define-color shade_color rgba(0, 0, 0, 0.36);
    @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
    /* Unfocused windows keep the same colors instead of flashing light. */
    @define-color theme_unfocused_fg_color @window_fg_color;
    @define-color theme_unfocused_text_color @view_fg_color;
    @define-color theme_unfocused_bg_color @window_bg_color;
    @define-color theme_unfocused_base_color @window_bg_color;
    @define-color theme_unfocused_selected_bg_color @accent_bg_color;
    @define-color theme_unfocused_selected_fg_color @accent_fg_color;
  '';

  # qt5ct and qt6ct color scheme. One color per QPalette role, in this
  # order: WindowText, Button, Light, Midlight, Dark, Mid, Text, BrightText,
  # ButtonText, Base, Window, Shadow, Highlight, HighlightedText, Link,
  # LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText,
  # PlaceholderText.
  qtRoles = lib.concatStringsSep ", ";
  activeColors = with p; [
    text
    surface0
    surface2
    surface1
    crust
    mantle
    text
    rosewater
    text
    mantle
    base
    crust
    accent
    crust
    blue
    lavender
    base
    base
    mantle
    text
    overlay1
  ];
  disabledColors = with p; [
    overlay0
    surface0
    surface2
    surface1
    crust
    mantle
    overlay0
    overlay0
    overlay0
    mantle
    base
    crust
    surface1
    overlay0
    overlay1
    overlay1
    base
    base
    mantle
    overlay0
    overlay0
  ];
  qtColorScheme = pkgs.writeText "qtct-catppuccin-mocha.conf" ''
    [ColorScheme]
    active_colors=${qtRoles activeColors}
    inactive_colors=${qtRoles activeColors}
    disabled_colors=${qtRoles disabledColors}
  '';

  qtctSettings = {
    Appearance = {
      style = "Fusion";
      custom_palette = true;
      color_scheme_path = "${qtColorScheme}";
      icon_theme = theme.icons.name;
      # File dialogs through the portal, the same ones GTK apps use.
      standard_dialogs = "xdgdesktopportal";
    };
    Fonts = {
      general = ''"${theme.fonts.sans.name},${toString theme.fonts.size}"'';
      fixed = ''"${theme.fonts.mono.name},${toString theme.fonts.size}"'';
    };
  };
in
lib.mkIf osConfig.my.desktop.enable {
  home.pointerCursor = {
    enable = true;
    inherit (theme.cursor) name package size;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      inherit (theme.gtk) name package;
    };
    iconTheme = {
      inherit (theme.icons) name package;
    };
    font = {
      inherit (theme.fonts.sans) name package;
      inherit (theme.fonts) size;
    };
    gtk3.extraCss = gtkCss;
    gtk4.extraCss = gtkCss;
  };

  # QT_QPA_PLATFORMTHEME itself is set for all sessions in
  # modules/nixos/desktop/sessions.nix.
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;
  };
}
