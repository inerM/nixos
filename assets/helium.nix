{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    pname = "helium";

    # https://github.com/imputnet/helium-linux/releases
    version = "0.19.2.1";

    xlib = n: pkgs.${lib.toLower n} or pkgs.xorg.${n};

    # the official prebuilt tarball, patched to run on nixos
    unwrapped = pkgs.stdenv.mkDerivation {
      inherit pname version;

      src = pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
        hash = "sha256-cHzzGeOj0qoGHKFddUh3vRi4sokghzjIKfywhzvH7Ns=";
      };

      nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
      ];

      # what `helium` binary links against
      buildInputs = [
        pkgs.stdenv.cc.cc.lib
        pkgs.glib
        pkgs.nspr
        pkgs.nss
        pkgs.atk
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.dbus
        pkgs.cups
        pkgs.expat
        pkgs.libxkbcommon
        pkgs.alsa-lib
        pkgs.libgbm
        pkgs.cairo
        pkgs.pango
        pkgs.systemd # libudev
        (xlib "libxcb")
        (xlib "libX11")
        (xlib "libXext")
        (xlib "libXcomposite")
        (xlib "libXdamage")
        (xlib "libXfixes")
        (xlib "libXrandr")
      ];

      # optional qt theming shims, i don't ship qt
      autoPatchelfIgnoreMissingDeps = ["libQt5*" "libQt6*"];

      dontStrip = true; # ~300MB binary, stripping is slow for nothing
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/opt/helium $out/bin
        cp -a . $out/opt/helium
        rm -f $out/opt/helium/chromedriver

        makeWrapper $out/opt/helium/helium $out/bin/helium \
          --prefix LD_LIBRARY_PATH : $out/opt/helium \
          --suffix LD_LIBRARY_PATH : /run/opengl-driver/lib \
          --set CHROME_VERSION_EXTRA nixos

        install -Dm444 helium.desktop $out/share/applications/helium.desktop
        install -Dm444 product_logo_256.png \
          $out/share/icons/hicolor/256x256/apps/helium.png

        runHook postInstall
      '';

      meta = {
        description = "Private, fast, and honest web browser based on ungoogled-chromium";
        homepage = "https://helium.computer";
        license = with lib.licenses; [gpl3Only bsd3];
        platforms = ["x86_64-linux"];
        mainProgram = "helium";
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };
    };
  in {
    packages.helium = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = unwrapped;
      flagSeparator = "=";
      flags = {
        "--ozone-platform-hint" = "auto";                   # wayland when available
        "--enable-features" = "WebRTCPipeWireCapturer";     # screen sharing on niri
      };
      runtimePkgs = [
        pkgs.xdg-utils       # xdg-open for links and downloads
      ];
      runtimeLibs = [        # dlopen'd at runtime
        pkgs.libGL
        pkgs.vulkan-loader
        pkgs.wayland
        pkgs.pipewire
        pkgs.libva
        pkgs.libpulseaudio
        pkgs.libkrb5
        pkgs.gtk3
      ];
    };
  };

  flake.nixosModules.app-helium = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helium
    ];
  };
}
