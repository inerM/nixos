{
  self,
  inputs,
  ...
}: {
  flake.wrappersModules.helix = {
    ...
  }: {
    config = {
      settings = {
        theme = "mono";

        editor = {
          true-color = true;
          color-modes = true;
          cursorline = true;
          bufferline = "multiple";
          line-number = "relative";
          indent-guides.render = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
      };

      themes.mono = {
        palette = {
          # neutral ramp
          bg   = self.theme.base00;
          bg1  = self.theme.base01;
          bg2  = self.theme.base02;
          gray = self.theme.comment; # readable neutral comments
          fg4  = self.theme.base04;
          fg3  = self.theme.base05;
          fg   = self.theme.base06;
          fg0  = self.theme.base07;

          # muted syntax accents, independent of neutral UI colors
          emph = self.theme.base07;
          num  = self.theme.base09;
          type = self.theme.base0A;
          str  = self.theme.base0B;
          spec = self.theme.base0C;
          fn   = self.theme.base0D;
          kw   = self.theme.base0E;
          dim  = self.theme.base0F;
          red  = self.theme.base08;
          wr = "#e72116";
        };

        # ---------- comments ----------
        "comment" = "gray";

        # ---------- keywords ----------
        "keyword" = {fg = "kw"; modifiers = ["bold"];};
        "keyword.control" = {fg = "kw"; modifiers = ["bold"];};
        "keyword.control.import" = {fg = "spec"; modifiers = ["bold"];};
        "keyword.directive" = {fg = "spec"; modifiers = ["bold"];};
        "keyword.storage" = {fg = "kw"; modifiers = ["bold"];};
        "keyword.operator" = "fg4";
        "label" = "spec";

        # ---------- functions ----------
        "function" = {fg = "fn"; modifiers = ["bold"];};
        "function.builtin" = {fg = "fn"; modifiers = ["bold"];};
        "function.method" = {fg = "fn"; modifiers = ["bold"];};
        "function.macro" = {fg = "fn"; modifiers = ["italic"];};

        # ---------- types ----------
        "type" = {fg = "type"; modifiers = ["italic"];};
        "type.builtin" = {fg = "type"; modifiers = ["italic"];};
        "type.parameter" = {fg = "type"; modifiers = ["italic"];};
        "constructor" = {fg = "type"; modifiers = ["italic"];};
        "namespace" = "fg3";
        "attribute" = "fn";

        # ---------- variables ----------
        "variable" = "fg";
        "variable.builtin" = {fg = "fg"; modifiers = ["italic"];};
        "variable.parameter" = {fg = "fg3"; modifiers = ["italic"];};
        "variable.other.member" = "fn";

        # ---------- constants ----------
        "constant" = "num";
        "constant.numeric" = "num";
        "constant.builtin" = {fg = "kw"; modifiers = ["bold"];};
        "constant.builtin.boolean" = {fg = "kw"; modifiers = ["bold"];};
        "constant.character" = "spec";
        "constant.character.escape" = {fg = "spec"; modifiers = ["bold"];};

        # ---------- strings ----------
        "string" = "str";
        "string.regexp" = "num";
        "string.special" = "num";
        "string.special.path" = {fg = "num"; modifiers = ["underlined"];};
        "string.special.url" = {fg = "fg3"; modifiers = ["underlined"];};
        "string.special.symbol" = "num";

        # ---------- operators / punctuation ----------
        "operator" = "fg4";
        "special" = "num";
        "tag" = {fg = "kw"; modifiers = ["bold"];};

        "punctuation" = "dim";
        "punctuation.delimiter" = "dim";
        "punctuation.bracket" = "dim";
        "punctuation.special" = "fg4";

        # ---------- markup ----------
        "markup.heading" = {fg = "fg0"; modifiers = ["bold"];};
        "markup.heading.marker" = "dim";
        "markup.list" = "kw";
        "markup.bold" = {modifiers = ["bold"];};
        "markup.italic" = {modifiers = ["italic"];};
        "markup.strikethrough" = {modifiers = ["crossed_out"];};
        "markup.link.url" = {fg = "fg3"; modifiers = ["underlined"];};
        "markup.link.text" = "fn";
        "markup.link.label" = "fn";
        "markup.quote" = {fg = "gray"; modifiers = ["italic"];};
        "markup.raw" = "str";

        # ---------- diff ----------
        "diff.plus" = "str";
        "diff.minus" = "red";
        "diff.delta" = "num";

        # ---------- diagnostics (distinguished by underline style) ----------
        "error" = {fg = "wr"; modifiers = ["bold"];};
        "warning" = "num";
        "info" = "fn";
        "hint" = "gray";
        "diagnostic.error" = {underline = {color = "wr"; style = "curl";};};
        "diagnostic.warning" = {underline = {color = "num"; style = "dashed";};};
        "diagnostic.info" = {underline = {color = "fn"; style = "dotted";};};
        "diagnostic.hint" = {underline = {color = "gray"; style = "dotted";};};
        "diagnostic.unnecessary" = {modifiers = ["dim"];};

        # ---------- ui ----------
        "ui.background" = {fg = "fg"; bg = "bg";};
        "ui.text" = "fg";
        "ui.text.focus" = {bg = "bg2";};
        "ui.text.inactive" = "gray";
        "ui.linenr" = "gray";
        "ui.linenr.selected" = {fg = "fg0"; modifiers = ["bold"];};
        "ui.cursorline.primary" = {bg = "bg1";};
        "ui.cursor.match" = {fg = "fg0"; bg = "gray"; modifiers = ["bold"];};

        # bright block with dark text so selections pop
        "ui.selection" = {fg = "bg"; bg = "fg3";};
        "ui.selection.primary" = {fg = "bg"; bg = "fg";};
        "ui.highlight" = {bg = "bg2";};

        "ui.statusline" = {fg = "fg4"; bg = "bg2";};
        "ui.statusline.inactive" = {fg = "gray"; bg = "bg1";};
        "ui.statusline.normal" = {fg = "bg"; bg = "fg3"; modifiers = ["bold"];};
        "ui.statusline.insert" = {fg = "bg"; bg = "str"; modifiers = ["bold"];};
        "ui.statusline.select" = {fg = "bg"; bg = "num"; modifiers = ["bold"];};

        "ui.bufferline" = {fg = "gray"; bg = "bg1";};
        "ui.bufferline.active" = {fg = "fg0"; bg = "bg2"; modifiers = ["bold"];};
        "ui.bufferline.background" = {bg = "bg1";};

        "ui.popup" = {fg = "fg3"; bg = "bg1";};
        "ui.help" = {fg = "fg3"; bg = "bg1";};
        "ui.menu" = {fg = "fg3"; bg = "bg1";};
        "ui.menu.selected" = {fg = "fg0"; bg = "bg2"; modifiers = ["bold"];};
        "ui.window" = "bg2";

        "ui.virtual.whitespace" = "bg2";
        "ui.virtual.indent-guide" = "bg2";
        "ui.virtual.ruler" = {bg = "bg1";};
        "ui.virtual.inlay-hint" = {fg = "gray"; modifiers = ["italic"];};
        "ui.virtual.jump-label" = {fg = "fg0"; modifiers = ["bold"];};
      };

    };
  };

  perSystem = {pkgs, ...}: {
    packages.helix =
    (inputs.wrappers.wrappers.helix.apply {
      inherit pkgs;
      imports = [self.wrappersModules.helix];
    }).wrapper;
  };
}
