{...}: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    # fonts
    fonts.packages = with pkgs; [
      ibm-plex
      (google-fonts.override {fonts = ["Space Grotesk" "Newsreader" "Instrument Serif"];})
      nerd-fonts.space-mono # terminal / code with Nerd glyphs
      nerd-fonts.symbols-only # icon glyphs for any font
      noto-fonts # Latin fallback coverage
      noto-fonts-cjk-sans # Japanese / CJK
      noto-fonts-cjk-serif
      noto-fonts-color-emoji # emoji
      material-symbols # icons used by bar / pill
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = ["Space Grotesk" "Noto Sans CJK JP"];
        serif = ["IBM Plex Serif"];
        monospace = ["IBM Plex Mono"];     
        emoji = ["Noto Color Emoji"];
      };
    };

    # cursor
    environment.systemPackages = [pkgs.bibata-cursors];
    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "20";
    };
  };
}
