{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.nightmode = pkgs.writeShellApplication {
      name = "nightmode";
      runtimeInputs = [ pkgs.wlsunset pkgs.procps ];
      text = ''
        state="''${XDG_RUNTIME_DIR:-/tmp}/nightmode-level"   # resets on reboot
        max=8
        step=500                                            # 6500K - level*500K

        level=0
        if [ -r "$state" ]; then level=$(cat "$state"); fi

        apply() {
          level=$1
          echo "$level" > "$state"
          pkill -x wlsunset 2>/dev/null || true
          if [ "$level" -gt 0 ]; then
            t=$(( 6500 - level * step ))
            # -T is 1K above -t, so the temperature stays effectively constant
            setsid wlsunset -t "$t" -T "$(( t + 1 ))" -S 06:00 -s 18:00 >/dev/null 2>&1 &
          fi
        }

        case "''${1:-toggle}" in
          up)     if [ "$level" -lt "$max" ]; then apply $(( level + 1 )); fi ;;  # warmer
          down)   if [ "$level" -gt 0 ];      then apply $(( level - 1 )); fi ;;  # cooler
          set)    apply "''${2:-0}" ;;
          off)    apply 0 ;;
          toggle) if [ "$level" -gt 0 ]; then apply 0; else apply 5; fi ;;        # 5 = 4000K
          status) echo "$level" ;;
        esac
      '';
    };
  };
}
