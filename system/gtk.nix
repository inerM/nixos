{self, ...}: {
  flake.nixosModules.gtk = {
    pkgs,
    lib,
    ...
  }: let
    t = self.theme;
    theme-name = "Gruvbox-Yellow-Dark-Medium";
    theme-package = (pkgs.gruvbox-gtk-theme.override {
      colorVariants = ["dark"];
      sizeVariants = ["standard"];
      themeVariants = ["yellow"];
      tweakVariants = ["medium" "macos"];
    }).overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # Update the Sass inputs before the package compiles GTK 3 and GTK 4.
        set_sass_color() {
          local pattern='^\$'"$2:"
          if ! grep -q "$pattern" "$1"; then
            echo "Missing Sass color $2 in $1" >&2
            return 1
          fi
          sed -i "s|$pattern.*|\$$2: $3;|" "$1"
        }

        palette=themes/src/sass/_color-palette-medium.scss
        set_sass_color "$palette" black '${t.base00}'
        set_sass_color "$palette" grey-750 '${t.base01}'
        set_sass_color "$palette" grey-700 '${t.base01}'
        set_sass_color "$palette" grey-650 '${t.base02}'
        set_sass_color "$palette" grey-850 '${t.bgDark}'
        set_sass_color "$palette" white '${t.base06}'
        set_sass_color "$palette" yellow-dark '${t.accent}'

        colors=themes/src/sass/_colors.scss
        set_sass_color "$colors" link '${t.base0D}'
        set_sass_color "$colors" link-visited '${t.base0E}'
        set_sass_color "$colors" suggested '${t.base0D}'
        set_sass_color "$colors" success '${t.base0B}'
        set_sass_color "$colors" warning '${t.base09}'
        set_sass_color "$colors" error '${t.base08}'

        # Use dark labels on the coral error and destructive-action fills.
        sed -i '/^@function on(/,/^}/s/\$brightness >= 156/\$brightness >= 140/' "$colors"
      '';
    });

    icon-theme-package = pkgs.gruvbox-plus-icons;
    icon-theme-name = "Gruvbox-Plus-Dark";

    gtksettings = ''
      [Settings]
      gtk-icon-theme-name = ${icon-theme-name}
      gtk-theme-name = ${theme-name}
    '';
  in {
    environment = {
      etc = {
        "xdg/gtk-3.0/settings.ini".text = gtksettings;
        "xdg/gtk-4.0/settings.ini".text = gtksettings;
      };
    };

    environment.variables = {
      GTK_THEME = theme-name;
    };

    programs = {
      dconf = {
        enable = lib.mkDefault true;
        profiles = {
          user = {
            databases = [
              {
                lockAll = false;
                settings = {
                  "org/gnome/desktop/interface" = {
                    font-name = "IBM Plex Sans 11";
                    gtk-theme = theme-name;
                    icon-theme = icon-theme-name;
                    color-scheme = "prefer-dark";
                  };
                };
              }
            ];
          };
        };
      };
    };

    environment.systemPackages = [
      theme-package
      icon-theme-package

      pkgs.gtk3
      pkgs.gtk4
    ];
  };
}
