{
  self,
  inputs,
  ...
}: {
  # elio (https://github.com/elio-fm/elio) – terminal file manager.
  flake.wrappersModules.elio = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      ...
    }: let
      t = self.theme;
      tomlFormat = config.pkgs.formats.toml {};

      # Recolor bundled icon rules too: extension/file rules override classes.
      bundledTheme = builtins.fromTOML (
        builtins.readFile "${inputs.elio}/assets/themes/default/theme.toml"
      );
      neutralIcons = rules: builtins.mapAttrs (_: _: { color = t.base04; }) rules;

      defaultTheme = {
        extensions = neutralIcons (bundledTheme.extensions or {});
        files = neutralIcons (bundledTheme.files or {});
        focused_entry = { bold = true; italic = false; underline = false; reversed = false; };
        palette = {
          bg = t.elioBg;
          chrome = t.elioBg;
          chrome_alt = t.elioBg;
          chip_text = t.elioBg;
          panel = t.elioBg;
          panel_alt = t.elioBg;
          surface = t.elioBg;
          elevated = t.base02;
          border = t.borderInactive;
          text = t.elioText;
          muted = t.comment;
          colored_names = false;
          accent = t.base05;
          accent_soft = t.base02;
          accent_text = t.base05;
          selected_bg = t.base02;
          selected_border = t.ember;
          selection_bar = t.ember;
          yank_bar = t.base0B;
          cut_bar = t.base08;
          progress_bar = t.base0D;
          trash_bar = t.base08;
          restore_bar = t.base0D;
          sidebar_active = t.base02;
          button_bg = t.elioBg;
          button_disabled_bg = t.elioBg;
          path_bg = t.elioBg;
        };

        preview.code = {
          fg = t.base06;
          bg = t.elioBg;
          selection_bg = t.base02;
          selection_fg = t.base06;
          caret = t.base06;
          line_highlight = t.elioBg;
          line_number = t.base03;
          comment = t.comment;
          string = t.base0C;
          constant = t.ember;
          keyword = t.base06;
          function = t.base05;
          type = t.base0A;
          parameter = t.base05;
          tag = t.base05;
          operator = t.base04;
          macro = t.base05;
          invalid = t.base08;
        };

        classes = {
          directory.color = t.base04;
          symlink_directory.color = t.base04;
          broken_symlink.color = t.base08;
          code.color = t.base04;
          config.color = t.base04;
          document.color = t.base04;
          license.color = t.base04;
          image.color = t.base04;
          audio.color = t.base04;
          video.color = t.base04;
          archive.color = t.base04;
          font.color = t.base04;
          data.color = t.base04;
          file.color = t.base04;
        };

        directories = {
          Desktop.color = t.base04;
          Documents.color = t.base04;
          Downloads.color = t.base04;
          Music.color = t.base04;
          Pictures.color = t.base04;
          Videos.color = t.base04;
          Projects.color = t.base04;
          dev.color = t.base04;
          notes.color = t.base04;
          ".config".color = t.base04;
        };
      };
    in {
      options = {
        settings = lib.mkOption {
          type = tomlFormat.type;
          default = {};
          description = ''
            Contents of elio's config.toml. When empty, no config.toml is generated
            and elio uses its built-in defaults.
          '';
        };

        theme = lib.mkOption {
          type = tomlFormat.type;
          default = {};
          description = ''
            Contents of elio's theme.toml. Merged on top of the theme generated
            from the system base16 palette, so you only set what you want to change.
          '';
        };

        extraTools = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Optional helpers that unlock richer previews (added to elio's PATH).";
        };
      };

      config = {
        # elio's main needs a newer rustc 1.99 above, than nixpkgs ships, so build it with
        # rust-overlay's toolchain (version taken from elio's rust-toolchain.toml)
        package = lib.mkDefault (
          let
            pkgs' = config.pkgs.extend inputs.rust-overlay.overlays.default;
            rust = pkgs'.rust-bin.stable."1.99.1".minimal;
            rustPlatform = pkgs'.makeRustPlatform {
              cargo = rust;
              rustc = rust;
            };
          in
            (inputs.elio.packages.${config.pkgs.stdenv.hostPlatform.system}.default.override {
              inherit rustPlatform;
            }).overrideAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                sed -i '/fn panel_block/,/^}/ s/BorderType::Rounded/BorderType::Plain/' \
                  src/ui/helpers.rs

                substituteInPlace src/ui/file_browser_pane.rs src/ui/preview_pane.rs \
                  --replace-fail 'BorderType::Rounded' 'BorderType::Plain'
              '';
            })
        );

        # user-supplied values win over the generated defaults
        theme = lib.mapAttrsRecursive (_: lib.mkDefault) defaultTheme;

        extraTools = with config.pkgs; [
          ffmpeg # video / audio metadata + thumbnails
          poppler-utils # pdf previews
          imagemagick # extra image formats
          zoxide # frecency jumps
        ];

        # kitty for the file-chooser portal: same theme/fonts as your terminal,
        # but built WITHOUT `shell`, because that appends the shell path to
        # kitty's argv and elio's `--portal-chooser` rejects extra arguments.
        # It is first on elio's PATH, so the portal service resolves `kitty` to it.
        runtimePkgs = [
          (inputs.wrappers.wrappers.kitty.apply {
            pkgs = config.pkgs;
            imports = [self.wrappersModules.kitty];
          }).wrapper
        ]
        ++ config.extraTools;

        constructFiles = {
          theme = {
            relPath = "xdg/elio/theme.toml";
            content = builtins.toJSON config.theme;
            builder = ''${config.pkgs.remarshal}/bin/json2toml "$1" "$2"'';
          };
          config = lib.mkIf (config.settings != {}) {
            relPath = "xdg/elio/config.toml";
            content = builtins.toJSON config.settings;
            builder = ''${config.pkgs.remarshal}/bin/json2toml "$1" "$2"'';
          };
        };

        # elio has no config-path flag/env var, only XDG_CONFIG_HOME.
        # NOTE: this is inherited by anything started from inside elio
        # (`!` shell, openers), same trade-off as other XDG-based wrappers.
        env.XDG_CONFIG_HOME = lib.dirOf (lib.dirOf config.constructFiles.theme.path);
      };
    }
  );

  # portal FileChooser (browser "Upload file" / "Save as", etc.).
  # `elio portal enable` writes into ~/.local/share and refuses /nix/store
  # launchers, so on NixOS the same two files are shipped from a package.
  flake.nixosModules.elioPortal-service = {
    pkgs,
    lib,
    ...
  }: let
    elio = self.packages.${pkgs.stdenv.hostPlatform.system}.elio;
    portalName = "io.github.elio_fm.elio.Portal";

    elioPortal = pkgs.symlinkJoin {
      name = "elio-portal";
      paths = [
        (pkgs.writeTextDir "share/xdg-desktop-portal/portals/elio.portal" ''
          [portal]
          DBusName=${portalName}
          Interfaces=org.freedesktop.impl.portal.FileChooser;
        '')
        (pkgs.writeTextDir "share/dbus-1/services/${portalName}.service" ''
          [D-BUS Service]
          Name=${portalName}
          Exec=${elio}/bin/elio --portal-service
        '')
      ];
    };

    routing = {
      default = lib.mkDefault ["gnome" "gtk"];
      "org.freedesktop.impl.portal.FileChooser" = ["elio"];
    };
  in {
    xdg.portal = {
      enable = lib.mkDefault true; # programs.niri.enable already turns this on
      extraPortals = [elioPortal];
      config = {
        niri = routing; # XDG_CURRENT_DESKTOP=niri
        common = routing; # fallback
      };
    };
  };

  perSystem = {pkgs, ...}: {
    packages.elio =
      (self.wrappersModules.elio.apply {
        inherit pkgs;
        settings = {
          portal.terminal = "kitty";
          places = {
            show_devices = false;
            entries = [
                "home"
                "root"
                { title = "Persist"; path = "/persist"; }
            ];
          };
        };
      }).wrapper;
  };
}
