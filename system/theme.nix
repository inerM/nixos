let
  theme = {
    base00 = "#121212"; # bg
    base01 = "#212121"; # lighter surface / status bars
    base02 = "#2c2c2c"; # selection bg (mono "selection" is darker than bg, so unusable here)
    base03 = "#5a5a5a"; # dim UI / invisibles (mono muted)
    base04 = "#8a8a8a"; # dark fg (status text)
    base05 = "#adadad"; # default text (mono dark_foreground)
    base06 = "#e0e0e0"; # fg (mono foreground)
    base07 = "#fafafa"; # light fg (mono bright_foreground)

    base08 = "#d9656a"; # red (from #e05f64): errors / deletions
    base09 = "#d9ad6d"; # sand (from #e0af68): numbers / constants
    base0A = "#bca686"; # warm stone (from #e0af68, softer mix): types
    base0B = "#8dd988"; # green (from #8be086): strings / additions
    base0C = "#57a3a5"; # teal (from #4fa3a6): escapes / options
    base0D = "#7ac3dc"; # blue (from #76c7e3): functions / attributes
    base0E = "#9186b6"; # mauve (from #9083b9): keywords / booleans
    base0F = "#949494"; # readable neutral punctuation (mono orange)

    comment = "#8a8a8a"; # readable comments, kept neutral

    accent = "#626262"; # neutral accent (mono)
    accentTint = "#7ac3dc"; # optional cool accent for focus / active states
    borderActive = "#4fa3a6"; # teal border (colour palette)
    borderInactive = "#2c2c2c";
    bgDark = "#0d0d0d"; # mono dark_background
    bgDarker = "#080808"; # mono darker_background
  };

  stripHash = str:
    if builtins.substring 0 1 str == "#"
    then builtins.substring 1 (builtins.stringLength str - 1) str
    else str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;
in {
  flake = {
    inherit theme themeNoHash;
  };
}
