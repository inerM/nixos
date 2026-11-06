
{
  self,
  ...
}: {
  flake.nixosModules.gtk = {
    pkgs,
    lib,
    ...
  }: let
    # ---------- GTK ----------
    themeName = "adw-gtk3-dark";
    themePackage = pkgs.adw-gtk3;

    # ---------- Icons ----------
    iconThemeName = "Obsidian";

    iconTheme = pkgs.runCommand "obsidian-icons" {} ''
      dir="$out/share/icons/${iconThemeName}"

      mkdir -p "$dir/scalable/places"

      # Icon theme metadata
      cat > "$dir/index.theme" <<'EOF'
      [Icon Theme]
      Name=Obsidian
      Comment=Minimal monochromatic icon theme
      Inherits=Adwaita,hicolor
      Directories=scalable/places

      [scalable/places]
      Size=48
      Type=Scalable
      MinSize=16
      MaxSize=512
      Context=Places
      EOF

      # Grey folder icon
      cat > "$dir/scalable/places/folder.svg" <<'EOF'
      <svg xmlns="http://www.w3.org/2000/svg"
           width="48" height="48"
           viewBox="0 0 48 48">

        <path
          d="M5 11
             C5 8.8 6.8 7 9 7
             H19 L23 12
             H39
             C41.2 12 43 13.8 43 16
             V37
             C43 39.2 41.2 41 39 41
             H9
             C6.8 41 5 39.2 5 37 Z"
          fill="${self.theme.base02}"/>

        <path
          d="M5 19
             C5 16.8 6.8 15 9 15
             H39
             C41.2 15 43 16.8 43 19
             V37
             C43 39.2 41.2 41 39 41
             H9
             C6.8 41 5 39.2 5 37 Z"
          fill="${self.theme.base04}"/>

        <path
          d="M9 15 H39"
          fill="none"
          stroke="${self.theme.base05}"
          stroke-width="1"
          opacity="0.35"/>

      </svg>
      EOF

      # Folder variants
      for name in \
        folder-open \
        folder-documents \
        folder-download \
        folder-music \
        folder-pictures \
        folder-videos \
        folder-publicshare \
        folder-templates \
        folder-desktop \
        folder-home \
        folder-remote \
        folder-saved-search \
        user-home \
        user-desktop \
        user-documents \
        user-download \
        user-music \
        user-pictures \
        user-videos \
        inode-directory
      do
        cp "$dir/scalable/places/folder.svg" \
           "$dir/scalable/places/$name.svg"
      done
    '';

    # ---------- GTK settings ----------
    gtkSettings = ''
      [Settings]
      gtk-theme-name = ${themeName}
      gtk-icon-theme-name = ${iconThemeName}
      gtk-font-name = IBM Plex Sans 11
      gtk-application-prefer-dark-theme = 1
    '';

    # ---------- Symbolic icon colors ----------
    gtkCss = ''
      * {
        -gtk-icon-palette:
          success ${self.theme.base05},
          warning ${self.theme.base04},
          error ${self.theme.base07};
      }
    '';
  in {
    # ---------- System-wide GTK configuration ----------
    environment.etc = {
      "xdg/gtk-3.0/settings.ini".text = gtkSettings;

      "xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name = ${iconThemeName}
        gtk-font-name = IBM Plex Sans 11
        gtk-application-prefer-dark-theme = 1
      '';

      "xdg/gtk-3.0/gtk.css".text = gtkCss;
      "xdg/gtk-4.0/gtk.css".text = gtkCss;
    };

    # ---------- dconf ----------
    programs.dconf = {
      enable = lib.mkDefault true;

      profiles.user.databases = [
        {
          lockAll = false;

          settings = {
            "org/gnome/desktop/interface" = {
              font-name = "IBM Plex Sans 11";
              gtk-theme = themeName;
              icon-theme = iconThemeName;
              color-scheme = "prefer-dark";
            };
          };
        }
      ];
    };

    # ---------- Packages ----------
    environment.systemPackages = [
      themePackage
      iconTheme
      pkgs.adwaita-icon-theme

      pkgs.gtk3
      pkgs.gtk4
    ];
  };
}
