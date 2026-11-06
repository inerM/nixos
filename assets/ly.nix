{ ... }: {
   flake.nixosModules.ly = { pkgs, ... }:
let
  # the .dur file wrapped as its own store package
  blackhole-dur = pkgs.runCommand "blackhole-dur" { } ''
    install -Dm644 ${./graphics/blackhole.dur} $out/share/ly/blackhole.dur
  '';
in
{
  services.displayManager.ly = {
    enable = true;
    settings = {
      full_color = true;
      animation = "dur_file";
      dur_file_path = "${blackhole-dur}/share/ly/blackhole.dur";
      dur_offset_alignment = "center";   # keeps the black hole centered behind everything

      box_position_h = 0.1;              # 0.0 = far left, 0.5 = center, 1.0 = far right
      box_position_v = 0.5;              # vertical, 0.5 = middle
    };
  };
 };
}

