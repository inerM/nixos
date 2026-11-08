let
  # Greek Noir inspired color palette, copied from ryoku.dev
  theme = {
    # Neutral surfaces and subdued text
    base00 = "#171717";
    base01 = "#242424";
    base02 = "#333333";
    base03 = "#757D75";
    base04 = "#AEAB94";
    base05 = "#BCBFBC";
    base06 = "#CCD0CF";
    base07 = "#DBDEDA";

    # Accents
    base08 = "#C1847A";
    base09 = "#C58C6A";
    base0A = "#AEAB94";
    base0B = "#88A57D";
    base0C = "#AAAAA2";
    base0D = "#A5AAA5";
    base0E = "#B0ABA5";
    base0F = "#8A8A8A";

    comment = "#92958E"; # grey1

    brand = "#F25623"; # Ryoku reference orange
    ember = "#C58C6A"; # Softer orange for small text and indicators
    elioBg = "#242424";
    elioText = "#BCBFBC";

    # Extras
    accent = "#BCBFBC";
    accentTint = "#AEAB94";
    borderActive = "#A5AAA5";
    borderInactive = "#4D4D4D";
    bgDark = "#141414";
    bgDarker = "#121212";

    # Subtle tinted backgrounds (diffs, visual selections)
    bgDiffRed = "#302626";
    bgDiffGreen = "#272D26";
    bgDiffBlue = "#282C2C";
    bgVisualRed = "#332B2B";
    bgVisualYellow = "#33312B";
    bgVisualGreen = "#2D322C";
    bgVisualBlue = "#2D3131";
    bgVisualPurple = "#302E31";
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

