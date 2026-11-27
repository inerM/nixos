{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    t = self.themeNoHash;

    # "88A57D" -> "38;2;136;165;125" (truecolor SGR)
    sgr = hex: let
      b = i: toString (lib.fromHexString (builtins.substring i 2 hex));
    in "38;2;${b 0};${b 2};${b 4}";

    c = {
      frame = sgr t.base03; # box borders
      logo = sgr t.base06; # ascii art
      hw = sgr t.base0B; # Hardware
      sw = sgr t.ember; # Software
      de = sgr t.base0D; # Desktop
      up = sgr t.base0E; # Uptime / Age / DT
    };

    # ---- box helpers ------------------------------------------------------
    width = 46;
    bar = n: lib.concatStrings (lib.replicate n "─");

    top = title: let
      inner = " ${title} ";
      l = (width - builtins.stringLength inner) / 2;
      r = width - builtins.stringLength inner - l;
    in {
      type = "custom";
      format = "{#${c.frame}}┌${bar l}${inner}${bar r}┐";
    };

    bottom = {
      type = "custom";
      format = "{#${c.frame}}└${bar width}┘";
    };

    gap = {type = "break";};

    # a module with a coloured key; `extra` can override/add anything
    m = type: col: key: extra: {inherit type key; keyColor = col;} // extra;

    # tree keys:  icon + label for the head line, branch + icon for children
    head = icon: label: "${icon} ${label}";
    mid = icon: "├─ ${icon}";
    end = icon: "╰─ ${icon}";

    config = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
            type = "kitty-direct";
            source = "${../assets/maomao.png}";
            width = 40;
            height = 17;
            padding = { top = 1; left = 2; right = 4; };
        };

      display = {
        separator = ": ";
      };

      modules = [
        # ── Hardware ─────────────────────────────────────────────
        (top "Hardware")
        (m "host" c.hw (head "" "PC") {format = "{2} ({3})";})
        (m "cpu" c.hw (mid "") {})
        (m "gpu" c.hw (mid "󰢮") {})
        (m "memory" c.hw (mid "🎟") {})
        (m "disk" c.hw (mid "") {
          format = "{size-used} / {size-total} ({size-percentage}) - {filesystem}";
        })
        bottom
        gap

        # ── Software ─────────────────────────────────────────────
        (top "Software")
        (m "os" c.sw (head "" "OS") {})
        (m "kernel" c.sw (mid "") {})
        (m "packages" c.sw (mid "") {})
        (m "shell" c.sw (end "") {})
        gap
        (m "wm" c.de (head "" "WM") {})
        (m "terminal" c.de (mid "") {})
        (m "terminalfont" c.de (end "") {})
        bottom
        gap

        # ── Uptime / Age / DT ────────────────────────────────────
        (top "Uptime / Age / DT")
        {
          type = "command";
          key = "OS Age ";
          keyColor = c.up;
          # birth time of /nix, since root is a tmpfs with impermanence
          text = "echo $(( ($(date +%s) - $(stat -c %W /nix)) / 86400 )) days";
        }
        (m "uptime" c.up "Uptime " {})
        (m "datetime" c.up "DateTime" {})
        bottom
        gap
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
      ];
    };

    fastfetchConf = pkgs.writeText "fastfetch.jsonc" (builtins.toJSON config);
  in {
    packages.fastfetch = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fastfetch;
      flags = {
        "--config" = "${fastfetchConf}";
      };
    };
  };
}
