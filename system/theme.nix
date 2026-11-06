let
  theme = {
    # Neutral ramp: black -> white (pure greys, no tint)
    base00 = "#111111"; # bg
    base01 = "#1c1c1c"; # darker surface / status bars
    base02 = "#2b2b2b"; # selection bg
    base03 = "#5c5c5c"; # dim UI / invisibles
    base04 = "#8a8a8a"; # dark fg (status text)
    base05 = "#b3b3b3"; # default text
    base06 = "#d9d9d9"; # fg
    base07 = "#f5f5f5"; # light fg

    # Muted accents: keep UI surfaces neutral, use hue for syntax meaning.
    base08 = "#c58f8f"; # dusty rose: errors / deletions
    base09 = "#c6ab86"; # sand: numbers / constants
    base0A = "#c2b99a"; # warm stone: types
    base0B = "#a5b49a"; # sage: strings / additions
    base0C = "#99b7b5"; # desaturated teal: escapes / options
    base0D = "#9eafc4"; # dusty blue: functions / attributes
    base0E = "#b2a0bd"; # muted mauve: keywords / booleans
    base0F = "#969696"; # readable neutral punctuation

    # Separate from base03 so existing neutral UI and GTK stay unchanged.
    comment = "#929292"; # readable comments on an older display
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
