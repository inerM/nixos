
{
  self,
  inputs,
  ...
}: {
  flake.wrappersModules.kitty = {
    config,
    lib,
    ...
  }: {
    options.shell = lib.mkOption {
      type = lib.types.str;
      default = "";
    };

    config = {
      appendFlag = lib.mkAfter (
        lib.optionals (config.shell != "") [config.shell]
      );

      env.FONTCONFIG_FILE = toString (config.pkgs.makeFontsConf {
        fontDirectories = [
          config.pkgs.ibm-plex # config.pkgs.nerd-fonts.space-mono 
          config.pkgs.nerd-fonts.symbols-only
          config.pkgs.noto-fonts-color-emoji
          config.pkgs.noto-fonts-cjk-sans 
        ];
      });

      settings = {
        enable_audio_bell = "no";
        background_opacity = 0.7;

        font_size = 10;
        font_family = "IBM Plex Mono";

        allow_remote_control = "yes";
        shell_integration = "enabled";

        cursor = self.theme.base06;
        cursor_text_color = self.theme.base00;
        cursor_shape = "block";

        cursor_trail = 10;
        cursor_trail_color = self.theme.base03;
        cursor_trail_decay = "0.2 0.5";

        window_padding_width = 14;
        confirm_os_window_close = 0;

        background = "#0b0b0b"; #self.theme.base00;
        foreground = self.theme.base06;

        selection_foreground = self.theme.base06;
        selection_background = self.theme.base02;

        active_tab_foreground = self.theme.base05;
        active_tab_background = self.theme.base02;
        inactive_tab_foreground = self.theme.base04;
        inactive_tab_background = self.theme.base01;

        color0 = self.theme.base00;
        color8 = self.theme.comment;

        color1 = self.theme.base08;
        color9 = self.theme.base08;

        color2 = self.theme.base0B;
        color10 = self.theme.base0B;

        color3 = self.theme.base0A;
        color11 = self.theme.base0A;

        color4 = self.theme.base0D;
        color12 = self.theme.base0D;

        color5 = self.theme.base0E;
        color13 = self.theme.base0E;

        color6 = self.theme.base0C;
        color14 = self.theme.base0C;

        color7 = self.theme.base05;
        color15 = self.theme.base07;

        # Nerd Font symbols
        symbol_map =
          "U+E000-U+F8FF,U+F0000-U+FFFFD Symbols Nerd Font Mono";
      };

      extraConfig = lib.concatMapStringsSep "\n" (m: "map ${m}") [
        "alt+1 goto_tab 1"
        "alt+2 goto_tab 2"
        "alt+3 goto_tab 3"
        "alt+4 goto_tab 4"
        "alt+5 goto_tab 5"
        "alt+6 goto_tab 6"
        "alt+7 goto_tab 7"
        "alt+8 goto_tab 8"
        "alt+9 goto_tab 9"
        "ctrl+shift+w close_tab"
        "ctrl+t new_tab_with_cwd"
        "ctrl+shift+t new_tab"
      ];
    };
  };

  perSystem = {pkgs, ...}: {
    packages.kitty =
      (inputs.wrappers.wrappers.kitty.apply {
        inherit pkgs;
        imports = [self.wrappersModules.kitty];
      }).wrapper;
  };
}
