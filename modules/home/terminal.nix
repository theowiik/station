# Ghostty, the terminal the keybinds open.
{ lib, osConfig, ... }:
let
  theme = osConfig.my.theme;
  c = theme.palette;
in
lib.mkIf osConfig.my.desktop.enable {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = theme.fonts.mono.name;
      font-size = theme.fonts.size;
      window-padding-x = 8;
      window-padding-y = 8;
      # niri and Hyprland tile the windows, so no title bar.
      window-decoration = "none";
      mouse-hide-while-typing = true;
      theme = "station";
    };

    # Terminal colors from the shared palette. The bright colors are the
    # lighter shade of each where the palette has one.
    themes.station = {
      foreground = c.text;
      background = c.base;
      cursor-color = c.${theme.accent};
      cursor-text = c.base;
      selection-foreground = c.text;
      selection-background = c.surface2;
      palette = [
        "0=${c.surface2}"
        "1=${c.red}"
        "2=${c.green}"
        "3=${c.yellow}"
        "4=${c.blue}"
        "5=${c.mauve}"
        "6=${c.teal}"
        "7=${c.subtext1}"
        "8=${c.overlay1}"
        "9=${c.maroon}"
        "10=${c.green}"
        "11=${c.yellow}"
        "12=${c.lavender}"
        "13=${c.mauve}"
        "14=${c.sky}"
        "15=${c.text}"
      ];
    };
  };
}
