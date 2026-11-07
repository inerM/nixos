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
          bg = self.theme.base00;
          bg1 = self.theme.base01;
          bg2 = self.theme.base02;
          gray = self.theme.comment;
          fg4 = self.theme.base04;
          fg3 = self.theme.base05;
          fg = self.theme.base06;
          fg0 = self.theme.base07;
          dim = self.theme.base0F;
          red = self.theme.base08;
          orange = self.theme.base09;
          yellow = self.theme.base0A;
          green = self.theme.base0B;
          aqua = self.theme.base0C;
          blue = self.theme.base0D;
          purple = self.theme.base0E;
        };

        "comment" = "gray";

        "keyword" = {fg = "red"; modifiers = ["bold"];};
        "keyword.directive" = "purple";
        "keyword.operator" = "orange";
        "label" = "yellow";

        "function" = {fg = "green"; modifiers = ["bold"];};
        "function.macro" = {fg = "green"; modifiers = ["bold" "italic"];};

        "type" = {fg = "yellow"; modifiers = ["italic"];};
        "constructor" = {fg = "green"; modifiers = ["bold"];};
        "namespace" = {fg = "yellow"; modifiers = ["italic"];};
        "attribute" = "purple";

        "variable" = "fg";
        "variable.builtin" = {fg = "purple"; modifiers = ["italic"];};
        "variable.parameter" = {fg = "fg3"; modifiers = ["italic"];};
        "variable.other.member" = "blue";

        "constant" = "purple";
        "constant.builtin" = {fg = "purple"; modifiers = ["italic"];};
        "constant.character" = "aqua";
        "constant.character.escape" = {fg = "green"; modifiers = ["bold"];};

        "string" = "aqua";
        "string.regexp" = "green";
        "string.special" = "yellow";
        "string.special.path" = {fg = "yellow"; modifiers = ["underlined"];};
        "string.special.url" = {fg = "blue"; modifiers = ["underlined"];};
        "string.special.uri" = {fg = "blue"; modifiers = ["underlined"];};
        "string.special.symbol" = "purple";

        "operator" = "orange";
        "special" = "yellow";
        "tag" = {fg = "orange"; modifiers = ["bold"];};

        "punctuation" = "dim";
        "punctuation.bracket" = "fg3";
        "punctuation.special" = "blue";

        # ---------- markup ----------
        "markup.heading" = {fg = "fg0"; modifiers = ["bold"];};
        "markup.heading.marker" = "dim";
        "markup.list" = "purple";
        "markup.bold" = {modifiers = ["bold"];};
        "markup.italic" = {modifiers = ["italic"];};
        "markup.strikethrough" = {modifiers = ["crossed_out"];};
        "markup.link.url" = {fg = "blue"; modifiers = ["underlined"];};
        "markup.link.text" = "blue";
        "markup.link.label" = "blue";
        "markup.quote" = {fg = "gray"; modifiers = ["italic"];};
        "markup.raw" = "aqua";

        # ---------- diff ----------
        "diff.plus" = "green";
        "diff.minus" = "red";
        "diff.delta" = "orange";

        # ---------- diagnostics (distinguished by underline style) ----------
        "error" = {fg = "red"; modifiers = ["bold"];};
        "warning" = "orange";
        "info" = "blue";
        "hint" = "gray";
        "diagnostic.error" = {underline = {color = "red"; style = "curl";};};
        "diagnostic.warning" = {underline = {color = "orange"; style = "dashed";};};
        "diagnostic.info" = {underline = {color = "blue"; style = "dotted";};};
        "diagnostic.hint" = {underline = {color = "gray"; style = "dotted";};};
        "diagnostic.unnecessary" = {modifiers = ["dim"];};

        # ---------- ui ----------
        "ui.background" = {fg = "fg"; bg = "bg";};
        "ui.text" = "fg";
        "ui.text.focus" = {bg = "bg2";};
        "ui.text.inactive" = "gray";
        "ui.linenr" = "gray";
        "ui.linenr.selected" = {fg = "yellow"; modifiers = ["bold"];};
        "ui.cursorline.primary" = {bg = "bg1";};
        "ui.cursor.match" = {fg = "bg"; bg = "yellow"; modifiers = ["bold"];};

        # bright block with dark text so selections pop
        "ui.selection" = {fg = "bg"; bg = "fg3";};
        "ui.selection.primary" = {fg = "bg"; bg = "fg";};
        "ui.highlight" = {bg = "bg2";};

        "ui.statusline" = {fg = "fg4"; bg = "bg2";};
        "ui.statusline.inactive" = {fg = "gray"; bg = "bg1";};
        "ui.statusline.normal" = {fg = "bg"; bg = "fg3"; modifiers = ["bold"];};
        "ui.statusline.insert" = {fg = "bg"; bg = "green"; modifiers = ["bold"];};
        "ui.statusline.select" = {fg = "bg"; bg = "orange"; modifiers = ["bold"];};

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
