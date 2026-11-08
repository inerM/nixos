{...}: {
  flake.nixosModules.fonts = {pkgs, ...}: {
    # fonts
    fonts.packages = [pkgs.ibm-plex];
    fonts.fontconfig.defaultFonts = {
      sansSerif = ["IBM Plex Sans"];
      serif = ["IBM Plex Serif"];
      monospace = ["IBM Plex Mono"];
    };

    # cursor
    environment.systemPackages = [pkgs.bibata-cursors];
    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "20";
    };
 };
}
