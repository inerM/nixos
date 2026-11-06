{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    ...
  }: let
    # hex colours without "#", which is what fish's set_color expects
    t = self.themeNoHash;
    red = "#e72116"; # shared muted error accent

    fishConf =
      pkgs.writeText "fishy-fishy"
      # fish
      ''
        # ---------- syntax highlighting ----------
        set -g fish_color_normal       ${t.base06}
        set -g fish_color_command      ${t.base0D} --bold
        set -g fish_color_keyword      ${t.base0E} --bold
        set -g fish_color_quote        ${t.base0B}
        set -g fish_color_param        ${t.base05}
        set -g fish_color_option       ${t.base0C}
        set -g fish_color_operator     ${t.base0C}
        set -g fish_color_redirection  ${t.base0A}
        set -g fish_color_end          ${t.base0E}
        set -g fish_color_escape       ${t.base0C} --bold
        set -g fish_color_comment      ${t.comment}
        set -g fish_color_error        ${red}
        set -g fish_color_valid_path   --underline
        set -g fish_color_autosuggestion ${t.base04}
        set -g fish_color_cancel       ${t.base03}
        set -g fish_color_search_match --background=${t.base02}
        set -g fish_color_selection    ${t.base00} --background=${t.base06}
        set -g fish_color_cwd          ${t.base04}
        set -g fish_color_user         ${t.base05}
        set -g fish_color_host         ${t.base05}
        set -g fish_color_host_remote  ${t.base04}
        set -g fish_color_status       ${red}

        # ---------- completion pager ----------
        set -g fish_pager_color_progress               ${t.base03}
        set -g fish_pager_color_prefix                 ${t.base07} --bold --underline
        set -g fish_pager_color_completion             ${t.base05}
        set -g fish_pager_color_description            ${t.comment}
        set -g fish_pager_color_selected_background    --background=${t.base02}
        set -g fish_pager_color_selected_completion    ${t.base07}
        set -g fish_pager_color_selected_description   ${t.base04}

        # ---------- prompt ----------
        function fish_prompt
          set -l last_status $status

          echo                      # blank line between prompts

          set_color ${t.base04}
          echo (prompt_pwd)

          if test $last_status -eq 0
            set_color ${t.base07}
          else
            set_color ${red}        # red if the last command failed
          end
          echo -n "❯ "
          set_color normal
        end
        function fish_mode_prompt
        end

        set fish_greeting
        fish_vi_key_bindings

        ${lib.getExe pkgs.zoxide} init fish | source

        function lf --wraps="lf" --description="lf - Terminal file manager (changing directory on exit)"
            cd "$(command lf -print-last-dir $argv)"
        end
      '';
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      flags = {
        "-C" = "source ${fishConf}";
      };
    };
  };
}
