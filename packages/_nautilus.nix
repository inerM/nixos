{ inputs, ... }:
{
  flake.nixosModules.app-nautilus-my-computer = { pkgs, ... }:
    let
      nmc = inputs.nautilus-my-computer.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      environment.systemPackages = [ pkgs.nautilus pkgs.nautilus-python nmc ];

      environment.pathsToLink = [
        "/lib/nautilus/extensions-4"
        "/share/nautilus-python/extensions"
      ];

      environment.sessionVariables = {
        NAUTILUS_4_EXTENSION_DIR = "/run/current-system/sw/lib/nautilus/extensions-4";
        PYTHONPATH = "${pkgs.python3Packages.pycairo}/${pkgs.python3.sitePackages}";
        GSETTINGS_SCHEMA_DIR = "${nmc}/share/glib-2.0/schemas";
      };
    };
}

