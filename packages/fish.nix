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
    t = self.themeNoHash;
    red = t.base08;

    fishConf =
      pkgs.writeText "fishy-fishy"
      # fish
      ''
        # syntax highlighting
        set -g fish_color_normal       ${t.base06}
        set -g fish_color_command      ${t.base06} --bold
        set -g fish_color_keyword      ${t.base07} --bold
        set -g fish_color_quote        ${t.base0C}
        set -g fish_color_param        ${t.base05}
        set -g fish_color_option       ${t.base0D}
        set -g fish_color_operator     ${t.base04}
        set -g fish_color_redirection  ${t.base0A}
        set -g fish_color_end          ${t.base04}
        set -g fish_color_escape       ${t.ember} --bold
        set -g fish_color_comment      ${t.comment} --italics
        set -g fish_color_error        ${red}
        set -g fish_color_valid_path   --underline
        set -g fish_color_autosuggestion ${t.base03}
        set -g fish_color_cancel       ${t.base03}
        set -g fish_color_search_match --background=${t.base02}
        set -g fish_color_selection    ${t.base06} --background=${t.base02}
        set -g fish_color_cwd          ${t.base0D}
        set -g fish_color_user         ${t.base05}
        set -g fish_color_host         ${t.base05}
        set -g fish_color_host_remote  ${t.base04}
        set -g fish_color_status       ${red}

        # completion pager 
        set -g fish_pager_color_progress               ${t.base03}
        set -g fish_pager_color_prefix                 ${t.base0A} --bold --underline
        set -g fish_pager_color_completion             ${t.base05}
        set -g fish_pager_color_description            ${t.comment}
        set -g fish_pager_color_selected_background    --background=${t.base02}
        set -g fish_pager_color_selected_completion    ${t.base06}
        set -g fish_pager_color_selected_description   ${t.base04}

        # prompt
        set -g fish_transient_prompt 1          # fish >= 4.1: old prompts collapse to "❯ "
        set -g fish_prompt_pwd_dir_length 0     # full path, like omp style = 'full'
        set -g VIRTUAL_ENV_DISABLE_PROMPT 1
        
        function __prompt_sep
          set_color ${t.comment}; echo -n "| "; set_color normal
        end
        
        function __prompt_char
          if test $argv[1] -eq 0
            set_color ${t.ember}
          else
            set_color ${red}
          end
          echo -n "❯ "
          set_color normal
        end
        
        function __prompt_git
          set -l st (command git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); or return
          set -l head; set -l oid; set -l ahead 0; set -l behind 0; set -l dirty 0
          for l in $st
            set -l f (string split " " -- $l)
            switch $l
              case "# branch.oid *"
                set oid (string sub -l 7 -- $f[3])
              case "# branch.head *"
                set head $f[3]
              case "# branch.ab *"
                set ahead (string replace + "" -- $f[3])
                set behind (string replace - "" -- $f[4])
              case "#*"
              case "*"
                set dirty 1
            end
          end
          test "$head" = "(detached)"; and set head @$oid
          set_color ${t.base0B}
          echo -n " "\ue0a0" $head"
          if test $dirty -eq 1
            set_color ${t.base0A}; echo -n " *"
          end
          set_color ${t.base0C}
          test $behind -gt 0; and echo -n " ↓"
          test $ahead -gt 0; and echo -n " ↑"
          set_color normal
        end
        
        function fish_prompt
          set -l last_status $status
          if contains -- --final-rendering $argv
            __prompt_char $last_status
            return
          end
          echo                                  # blank line between prompts
        
          # ssh host
          if set -q SSH_CLIENT
            set_color ${t.base0B}; echo -n "󰒋 $hostname "; set_color normal; __prompt_sep
          end
          # devshell labels: DEVSHELL_NAME="name/color|name2/color2"
          if set -q DEVSHELL_NAME
            for part in (string split "|" -- $DEVSHELL_NAME)
              set -l sub (string split "/" -- $part)
              if test (count $sub) -eq 2
                set_color $sub[2]; echo -n $sub[1]; set_color normal; echo -n " "; __prompt_sep
              end
            end
          end
          # python venv
          if set -q VIRTUAL_ENV
            set_color ${t.base0A}; echo -n "🐍 venv "; set_color normal; __prompt_sep
          end
          # generic nix shell (nix-shell / nix develop without a DEVSHELL_NAME)
          if set -q IN_NIX_SHELL; and not set -q DEVSHELL_NAME
            set_color ${t.base0D}; echo -n \uf313" nsh "; set_color normal; __prompt_sep
          end
        
          set_color --italics ${t.base05}; echo -n (prompt_pwd); set_color normal
          __prompt_git
          echo
          __prompt_char $last_status
        end
        
        # command duration, only if >= 5s
        function fish_right_prompt
          contains -- --final-rendering $argv; and return
          set -q CMD_DURATION; and test $CMD_DURATION -ge 5000; or return
          set -l s (math -s0 "floor($CMD_DURATION / 1000)")
          set -l h (math -s0 "floor($s / 3600)")
          set -l m (math -s0 "floor(($s % 3600) / 60)")
          set -l r (math -s0 "$s % 60")
          set -l out
          test $h -gt 0; and set -a out "$h"h
          test $m -gt 0; and set -a out "$m"m
          set -a out "$r"s
          set_color ${t.base0A}; echo -n (string join " " $out); set_color normal
        end
        
        function fish_title
          echo fish in (path basename $PWD)
        end
        
        function fish_mode_prompt
        end

        fish_vi_key_bindings
        set -g fish_greeting

        ${lib.getExe pkgs.zoxide} init fish | source

        # keybinds (vi insert mode), optional
        bind -M insert ctrl-right forward-word
        bind -M insert ctrl-left  backward-word
        bind -M insert ctrl-delete kill-word
        
        # fzf: ctrl-t files, ctrl-r history, alt-c cd
        ${lib.getExe pkgs.fzf} --fish | source
        
        # keep fish inside nix-shell / nix develop
        ${lib.getExe pkgs.nix-your-shell} fish | source
        
        # optional: use fd (already in your env) for faster, .gitignore-aware search
        set -gx FZF_DEFAULT_COMMAND "${lib.getExe pkgs.fd} --type f --hidden --exclude .git"
        set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND   "${lib.getExe pkgs.fd} --type d --hidden --exclude .git"
        set -gx FZF_ALT_C_OPTS      "--preview '${lib.getExe pkgs.eza} --tree --level=2 --icons=auto {}'"
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

