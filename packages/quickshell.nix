{inputs, ...}: {
  perSystem = {pkgs, self', lib, ...}: let
    fontsConf = pkgs.writeText "fonts.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
        <dir>${pkgs.nerd-fonts.geist-mono}/share/fonts</dir>
      </fontconfig>
    '';
  in {
    packages.quickshell = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.quickshell;
      runtimePkgs = [
        pkgs.fd              # file listing
        pkgs.fzf             # fuzzy filter for f mode
        pkgs.file            # mime detection for nvim-vs-xdg-open
        pkgs.cliphist        # clipboard history
        pkgs.wl-clipboard    # wl-copy / wl-paste
        pkgs.wtype           # typing emoji / pasting
        pkgs.xdg-utils       # xdg-open
        pkgs.wireplumber     # wpctl (volume, mute)
        pkgs.brightnessctl
        pkgs.bluez           # bluetoothctl
        pkgs.procps          # pgrep (clipboard watcher check)
        pkgs.gnugrep         # emoji parsing
        pkgs.coreutils       # sleep etc.

        self'.packages.nightmode
      ];
      env = {
        FONTCONFIG_FILE = "${fontsConf}";
        EMOJI_FILE = "${pkgs.unicode-emoji}/share/unicode/emoji/emoji-test.txt";
        TERMINAL_BIN = lib.getExe self'.packages.terminal;
        EDITOR_BIN = lib.getExe self'.packages.helix;   
      };
      flags = {
        "-p" = "${inputs.quickshell-config}";
      };
    };
  };
}
