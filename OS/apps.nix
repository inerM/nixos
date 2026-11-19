{ inputs, lib, self, ... }: {
  flake.nixosModules.apps = {
       imports = lib.attrValues
        (lib.filterAttrs (name: _: lib.hasPrefix "app-" name) self.nixosModules);
  };


  flake.nixosModules.app-defaults = { pkgs, lib, ... }: let
    system = pkgs.stdenv.hostPlatform.system;
    helix = self.packages.${system}.helix;

    kitty = (inputs.wrappers.wrappers.kitty.apply {
      inherit pkgs;
      imports = [ self.wrappersModules.kitty ];
    }).wrapper;

    textTypes = [
      "text/plain" "text/markdown" "text/css" "text/csv"
      "text/x-python" "text/x-csrc" "text/x-chdr" "text/x-c++src" "text/x-c++hdr"
      "text/x-java" "text/x-go" "text/rust" "text/x-rust" "text/x-lua"
      "text/x-makefile" "text/x-nix" "text/x-toml" "text/javascript"
      "application/javascript" "application/json" "application/toml"
      "application/x-yaml" "application/yaml" "application/x-shellscript"
      "application/xml" "text/xml"   # helium claims these too
    ];

    # helix is a TUI, so it needs a desktop entry that launches it in kitty
    helixDesktop = pkgs.makeDesktopItem {
      name = "helix-kitty";
      desktopName = "Helix";
      genericName = "Text Editor";
      exec = "${lib.getExe kitty} --class helix-edit ${lib.getExe helix} %F";
      terminal = false;
      categories = [ "Utility" "TextEditor" ];
      mimeTypes = textTypes;
    };

    assign = app: types: lib.genAttrs types (_: app);
  in {
    environment.systemPackages = [ helixDesktop ];

    xdg.mime.defaultApplications =
      assign "helium.desktop" [
        "text/html" "application/xhtml+xml"
        "x-scheme-handler/http" "x-scheme-handler/https"
        "x-scheme-handler/about" "x-scheme-handler/unknown"
      ]
      // assign "org.pwmt.zathura.desktop" [
        "application/pdf" "application/epub+zip" "application/oxps"
      ]
      // assign "imv.desktop" [
        "image/png" "image/jpeg" "image/gif" "image/webp"
        "image/bmp" "image/tiff" "image/avif"
      ]
      // assign "vlc.desktop" [
        "video/matroska"
        "application/x-matroska" "video/x-matroska-3d" "audio/x-matroska"
        "video/mp4" "video/x-matroska" "video/webm" "video/quicktime"
        "video/x-msvideo" "video/mpeg" "video/ogg" "video/x-flv"
        "video/3gpp" "video/x-ms-wmv" "video/x-m4v"
        "audio/mpeg" "audio/flac" "audio/x-flac" "audio/ogg" "audio/mp4"
        "audio/aac" "audio/x-wav" "audio/x-opus+ogg" "audio/x-vorbis+ogg"
      ]
      // assign "helix-kitty.desktop" textTypes;
  };
}

