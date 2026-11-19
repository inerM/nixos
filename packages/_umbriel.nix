{
  inputs,
  self,
  ...
}: let
  # Umbriel wrapper with declarative defaults and optional live TOML overrides.
  # The generated entrypoint contains ONLY includes, so writable overrides win.
  umbrielModule = {
    config,
    lib,
    wlib,
    ...
  }: let
    quickshellExe =
      lib.getExe
      self.packages.${config.pkgs.stdenv.hostPlatform.system}.quickshell;

    launcher = fn: "spawn ${quickshellExe} ipc call launcher ${fn}";

    # Screenshots: umbriel has no built-in screenshot action, so use grim/slurp.
    # Saves to ~/Pictures/Screenshots and copies to the clipboard.
    screenshot = name: text:
      lib.getExe (config.pkgs.writeShellApplication {
        inherit name text;
        runtimeInputs = with config.pkgs; [grim slurp wl-clipboard coreutils];
      });

    screenshotRegion = screenshot "screenshot-region" ''
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      f="$dir/$(date +%F_%H-%M-%S).png"
      grim -g "$(slurp)" "$f" && wl-copy < "$f"
    '';

    screenshotScreen = screenshot "screenshot-screen" ''
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      f="$dir/$(date +%F_%H-%M-%S).png"
      grim "$f" && wl-copy < "$f"
    '';

    # Mod+1..0 -> workspace 1..10, Mod+Shift+1..0 -> move column there
    workspaceBinds = lib.listToAttrs (
      lib.concatMap (
        i: let
          key =
            if i == 10
            then "0"
            else toString i;
        in [
          {
            name = "Mod+${key}";
            value = "workspace-switch ${toString i}";
          }
          {
            name = "Mod+Shift+${key}";
            value = "column-move-to-workspace ${toString i}";
          }
        ]
      ) (lib.range 1 10)
    );
  in {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };

    options.settings = lib.mkOption {
      type = wlib.types.structuredValueWith {
        nullable = false;
        typeName = "TOML";
      };
      default = {};
      description = ''
        Umbriel configuration, serialized to TOML.
        See https://docs.noctalia.dev/umbriel/configuration/
      '';
    };

    config = {
      package = lib.mkDefault inputs.umbriel.packages.${config.pkgs.stdenv.hostPlatform.system}.default;

      # Umbriel's built-in Xwayland needs Xwayland on PATH
      # (replaces xwayland-satellite from the niri setup).
      extraPackages = [config.pkgs.xwayland];

      # Explicit entrypoint. The included Nix-generated base is immutable,
      # while user override files are optional and watched by Umbriel.
      flags."-c" = config.constructFiles.generatedConfig.path;

      constructFiles.baseConfig = {
        content = builtins.toJSON config.settings;
        relPath = "umbriel/base.toml";
        builder = ''${config.pkgs.remarshal}/bin/json2toml "$1" "$2"'';
      };

      # IMPORTANT: Umbriel applies including-file settings last. This file
      # must therefore contain no settings apart from [include].
      # Files are loaded in order: base, individual overrides, final override.
      constructFiles.generatedConfig = {
        content = builtins.toJSON {
          include = {
            files = [config.constructFiles.baseConfig.path];
            optional.files = [
              "~/.config/umbriel/appearance.toml"
              "~/.config/umbriel/input.toml"
              "~/.config/umbriel/layout.toml"
              "~/.config/umbriel/keybinds.toml"
              "~/.config/umbriel/window-rules.toml"
              "~/.config/umbriel/noctalia.toml"
              "~/.config/umbriel/override.toml"
            ];
          };
        };
        relPath = "umbriel/config.toml";
        builder = ''${config.pkgs.remarshal}/bin/json2toml "$1" "$2"'';
      };

      # Session / unit files embed the original store path; repoint them at the wrapper.
      filesToPatch = [
        "share/applications/*.desktop"
        "share/wayland-sessions/*.desktop"
        "lib/systemd/user/*.service"
        "share/systemd/user/*.service"
      ];

      # Forward providedSessions (if the package has it) so display managers still see the session.
      passthru = lib.optionalAttrs
        (config.package ? passthru && config.package.passthru ? providedSessions)
        {inherit (config.package.passthru) providedSessions;};

      settings = {
        general = {
          mod_key = "Super";
          show_cheatsheet = false; # was: hotkey-overlay skip-at-startup
          xwayland = true;

          autostart = [
            quickshellExe
            "${lib.getExe config.pkgs.swaybg} -i ${self.wallpaper} -m fill"
          ];
        };

        appearance = {
          prefer_no_csd = true;
          border_width = 1; # was: focus-ring width
          corner_radius = 0; # niri default was square; umbriel's default is 10

          shadow = {
            enabled = false; # no workspace/window shadows
            softness = 20;
            offset_x = 0;
            offset_y = 0;
          };

          blur = {
            enabled = true;
            passes = 1;
            noise = 0.05;
            saturation = 1.0;
            brightness = 1.0; # umbriel defaults darken the blur slightly; niri didn't
            contrast = 1.0;
          };
        };

        colors = {
          shadow = "${self.theme.base00}80";
          border = {
            focused = self.theme.base05;
            unfocused = self.theme.base02;
          };
        };

        input = {
          focus.follows_mouse = "sloppy";

          keyboard.layout = "us";

          touchpad = {
            natural_scroll = true;
            tap = true;
            disable_while_typing = true;
          };

          mouse.accel_profile = "flat";

          cursor = {
            theme = "Bibata-Modern-Classic";
            size = 20;
          };
        };

        layout = {
          mode = "scrolling";
          gap = 4;

          scrolling = {
            default_extent_fraction = 0.65;
            center_underfull_strip = true; # was: always-center-single-column
          };
        };

        keybinds =
          {
            "Mod+Space" = launcher "apps";
            "Mod+Alt+Space" = launcher "files";
            "Mod+Shift+V" = launcher "clipboard";
            "Mod+Period" = launcher "emoji";

            "Mod+Return" = "spawn ${config.terminal}";

            "Mod+Q" = "window-close";
            "Mod+F" = "window-toggle-maximize";
            "Mod+G" = "window-toggle-fullscreen";
            "Mod+Shift+F" = "window-toggle-floating";
            "Mod+C" = "column-center";

            "Mod+H" = "window-focus-left";
            "Mod+L" = "window-focus-right";
            "Mod+K" = "window-focus-up";
            "Mod+J" = "window-focus-down";

            "Mod+Left" = "window-focus-left";
            "Mod+Right" = "window-focus-right";
            "Mod+Up" = "window-focus-up";
            "Mod+Down" = "window-focus-down";

            "Mod+Shift+H" = "column-move-left";
            "Mod+Shift+L" = "column-move-right";
            "Mod+Shift+K" = "window-move-up";
            "Mod+Shift+J" = "window-move-down";

            "Mod+Tab" = "overview-toggle";

            # Audio
            "XF86AudioRaiseVolume" = "spawn wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "spawn wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

            # Resize (niri's +-5% column width / window height)
            "Mod+Ctrl+H" = "window-modify-primary-extent -0.05";
            "Mod+Ctrl+L" = "window-modify-primary-extent +0.05";
            "Mod+Ctrl+J" = "window-modify-secondary-extent -0.05";
            "Mod+Ctrl+K" = "window-modify-secondary-extent +0.05";

            # Mouse navigation (same direction mapping as your niri binds)
            "Mod+WheelDown" = "window-focus-left";
            "Mod+WheelUp" = "window-focus-right";
            "Mod+Ctrl+WheelDown" = {
              action = "workspace-next";
              cooldown_ms = 150;
            };
            "Mod+Ctrl+WheelUp" = {
              action = "workspace-previous";
              cooldown_ms = 150;
            };

            # Screenshots (Alt+Print / window screenshot has no simple equivalent)
            "Print" = "spawn ${screenshotRegion}";
            "Ctrl+Print" = "spawn ${screenshotScreen}";
          }
          // workspaceBinds;

        window_rule = [
          # kitty: blurred backdrop (optimized = niri's xray)
          {
            match.app_id = "^kitty$";
            blur = true;
            blur_optimized = true;
          }

          # termfilechooser: floating, blurred, non-xray (live content behind it)
          {
            match.app_id = "^termfilechooser$";
            default_floating = true;
            # Umbriel uses pixel dimensions for default_size.
            default_size = [880 600];
            blur = true;
            blur_optimized = false;
          }

          {
            match.app_id = "^helium$";
            default_maximize = true;
          }
        ];
      };
    };
  };
in {
  flake.wrappersModules.umbriel = umbrielModule;

  perSystem = {pkgs, ...}: {
    packages.umbriel =
      (inputs.wrappers.lib.wrapModule umbrielModule).wrap {
        inherit pkgs;
      };
  };
}
