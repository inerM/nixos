let
  # Swaystation’s charcoal terminal background and Gruvbox Material accents.
  theme = {
    # Charcoal surfaces and warm Gruvbox text
    base00 = "#222222"; # Swaystation Foot background
    base01 = "#282828"; # bg1 / status bars
    base02 = "#383838"; # selection / raised surfaces
    base03 = "#7c6f64"; # grey0 / dim UI, invisibles
    base04 = "#928374"; # grey1 / status text
    base05 = "#d4be98"; # fg0 / default text
    base06 = "#ebdbb2"; # normal editor text
    base07 = "#fff4d2"; # Swaystation Foot foreground

    # Accents
    base08 = "#ea6962"; # red: keywords / errors
    base09 = "#e78a4e"; # orange: operators / warnings
    base0A = "#d8a657"; # yellow: types
    base0B = "#a9b665"; # green: functions / additions
    base0C = "#89b482"; # aqua: strings / options
    base0D = "#83a598"; # blue: members / links
    base0E = "#d3869b"; # purple: annotations / literals
    base0F = "#a89984"; # grey2: punctuation

    comment = "#928374"; # grey1

    # Extras
    accent = "#d8a657";
    accentTint = "#83a598";
    borderActive = "#d8a657";
    borderInactive = "#383838";
    bgDark = "#181818";
    bgDarker = "#141414";

    # Subtle tinted backgrounds (diffs, visual selections)
    bgDiffRed = "#3c1f1e";
    bgDiffGreen = "#32361a";
    bgDiffBlue = "#0d3138";
    bgVisualRed = "#442e2d";
    bgVisualYellow = "#473c29";
    bgVisualGreen = "#333e34";
    bgVisualBlue = "#2e3b3b";
    bgVisualPurple = "#3c333b";
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
