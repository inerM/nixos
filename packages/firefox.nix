{ ... }:

{
  flake.nixosModules.app-firefox = { ... }: {
    programs.firefox = {
      enable = true;
      # preferences = {
      #   "ui.systemUsesDarkTheme" = 1;
      #   "layout.css.prefers-color-scheme.content-override" = 2;
      # };
    };
  };
}
