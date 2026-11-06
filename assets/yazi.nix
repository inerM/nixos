{self, ...}: {
  flake.nixosModules.app-yazi = {pkgs, ...}: let
    t = self.theme;
    red = t.base08; # shared muted error accent
    # Soft graphite highlight with readable light-gray text.
    selected = {fg = "#c4c4c4"; bg = "#353535"; bold = false;};
    ic = hex: builtins.fromJSON ''"\u${hex}"''; # nerd-font glyph from codepoint

    # ---------- code preview colours (yazi uses a .tmTheme for this) ----------
    rule = name: scope: fg: style: ''
      <dict>
        <key>name</key><string>${name}</string>
        <key>scope</key><string>${scope}</string>
        <key>settings</key>
        <dict>
          <key>foreground</key><string>${fg}</string>
          ${pkgs.lib.optionalString (style != "") "<key>fontStyle</key><string>${style}</string>"}
        </dict>
      </dict>
    '';

    monoTmTheme = pkgs.writeText "mono.tmTheme" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>name</key><string>mono</string>
        <key>settings</key>
        <array>
          <dict>
            <key>settings</key>
            <dict>
              <key>background</key><string>${t.base00}</string>
              <key>foreground</key><string>${t.base06}</string>
              <key>caret</key><string>${t.base06}</string>
              <key>selection</key><string>${t.base02}</string>
              <key>lineHighlight</key><string>${t.base01}</string>
            </dict>
          </dict>
          ${rule "comment" "comment" t.comment ""}
          ${rule "string" "string" t.base0B ""}
          ${rule "regex / escape" "string.regexp, constant.character.escape" t.base0C ""}
          ${rule "constant" "constant, constant.numeric" t.base09 ""}
          ${rule "boolean / builtin" "constant.language" t.base0E "bold"}
          ${rule "keyword" "keyword, storage" t.base0E "bold"}
          ${rule "operator" "keyword.operator" t.base04 ""}
          ${rule "function" "entity.name.function, support.function, meta.function-call" t.base0D "bold"}
          ${rule "type" "entity.name.type, entity.name.class, support.type, support.class, storage.type" t.base0A "italic"}
          ${rule "variable" "variable" t.base06 ""}
          ${rule "parameter" "variable.parameter" t.base05 "italic"}
          ${rule "punctuation" "punctuation" t.base0F ""}
          ${rule "tag" "entity.name.tag" t.base0E "bold"}
          ${rule "attribute" "entity.other.attribute-name" t.base0D ""}
          ${rule "heading" "markup.heading, entity.name.section" t.base07 "bold"}
          ${rule "invalid" "invalid" red ""}
        </array>
      </dict>
      </plist>
    '';

    # ---------- yazi theme.toml ----------
    theme = {
      mgr = {
        cwd = {fg = t.base04;};
        find_keyword = {fg = t.base05; bold = true; underline = true;};
        find_position = {fg = t.base05; bold = true;};
        symlink_target = {fg = t.base04; italic = true;};
        marker_copied = {fg = t.base05; bg = t.base05;};
        marker_cut = {fg = t.base03; bg = t.base03;};
        marker_marked = {fg = t.base04; bg = t.base04;};
        marker_selected = {fg = t.base04; bg = t.base04;};
        count_copied = {fg = t.base00; bg = t.base05;};
        count_cut = {fg = t.base00; bg = t.base04;};
        count_selected = selected;
        border_symbol = "│";
        border_style = {fg = t.base03;};
        syntect_theme = "${monoTmTheme}";
      };

      # Current Yazi uses indicator styles for the hovered row.
      indicator = {
        parent = selected;
        current = selected;
        preview = selected;
      };

      tabs = {
        active = selected;
        inactive = {fg = t.base04; bg = t.base02;};
      };

      mode = {
        normal_main = selected;
        normal_alt = {fg = t.base06; bg = t.base02;};
        select_main = selected;
        select_alt = {fg = t.base05; bg = t.base02;};
        unset_main = {fg = t.base00; bg = t.base04; bold = true;};
        unset_alt = {fg = t.base04; bg = t.base02;};
      };

      status = {
        perm_sep = {fg = t.base03;};
        perm_type = {fg = t.base06;};
        perm_read = {fg = t.base05;};
        perm_write = {fg = t.base05; bold = true;};
        perm_exec = {fg = t.base04;};
        progress_label = {fg = t.base05; bold = true;};
        progress_normal = {fg = t.base06; bg = t.base02;};
        progress_error = {fg = red; bg = t.base02;};
      };

      which = {
        cols = 3;
        mask = {bg = t.base01;};
        cand = {fg = t.base06;};
        rest = {fg = t.base04;};
        desc = {fg = t.base04;};
        separator = "  ";
        separator_style = {fg = t.base03;};
      };

      confirm = {
        border = {fg = t.base04;};
        title = {fg = t.base05; bold = true;};
        content = {fg = t.base05;};
        list = {fg = t.base05;};
        btn_yes = selected;
        btn_no = {fg = t.base05;};
      };

      notify = {
        title_info = {fg = t.base06;};
        title_warn = {fg = t.base09; bold = true;};
        title_error = {fg = red; bold = true;};
      };

      input = {
        border = {fg = t.base04;};
        title = {fg = t.base05;};
        value = {fg = t.base06;};
        selected = {bg = t.base02;};
      };

      pick = {
        border = {fg = t.base04;};
        active = selected;
        inactive = {fg = t.base05;};
      };

      cmp = {
        border = {fg = t.base04;};
        active = selected;
        inactive = {fg = t.base05;};
      };

      tasks = {
        border = {fg = t.base04;};
        title = {fg = t.base05;};
        hovered = selected;
      };

      help = {
        on = {fg = t.base05; bold = true;};
        run = {fg = t.base05;};
        desc = {fg = t.base04;};
        hovered = selected;
        footer = {fg = t.base04;};
      };

      # Mostly neutral file list, with muted hints for file types
      filetype.rules = [
        {url = "*"; is = "orphan"; fg = red;}
        # Match directories before executable files; directories can be executable too.
        {url = "*/"; fg = t.base05; bold = false;}
        {url = "*"; is = "exec"; fg = t.base05; bold = false;}
        {mime = "image/*"; fg = t.base0C;}
        {mime = "{audio,video}/*"; fg = t.base0A;}
        {mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = t.base0E;}
        {mime = "application/{pdf,doc,rtf}"; fg = t.base0D;}
        {url = "*"; fg = t.base05;}
      ];

      # icons: same shape idea as the default, but all grey
      icon.prepend_globs = [
        {url = ".git/"; text = ic "e702"; fg = t.base04;}
        {url = "*/"; text = ic "e5ff"; fg = t.base05;}
        {url = "*.nix"; text = ic "f313"; fg = t.base04;}
        {url = "*.md"; text = ic "e73e"; fg = t.base04;}
        {url = "*.lock"; text = ic "f023"; fg = t.base04;}
        {url = "*.toml"; text = ic "e615"; fg = t.base04;}
        {url = "*.yaml"; text = ic "e615"; fg = t.base04;}
        {url = "*.yml"; text = ic "e615"; fg = t.base04;}
        {url = "*.json"; text = ic "e615"; fg = t.base04;}
        {url = "*"; text = ic "f15b"; fg = t.base04;}
      ];
    };
  in {
    environment.systemPackages = [
      (pkgs.yazi.override {settings = {inherit theme;};})
    ];
  };
}
