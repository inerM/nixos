{ self, ... }:

{
  flake.nixosModules.ext-service = { pkgs, ... }: let
  modules = with self.nixosModules; [
      nixsettings
      ];

  in {

    imports = modules;
    services.upower.enable = true;
    
    services.power-profiles-daemon.enable = true;
    services.udev.packages = [ pkgs.brightnessctl ];
    services.dbus.enable = true;
    security.polkit.enable = true;
  
    services.udisks2.enable = true; # mount USB drives
    services.gvfs.enable = true;    # trash, network mounts in file managers

    environment.systemPackages = [
        pkgs.wl-screenrec
        pkgs.slurp
    ];
    # services.printing.enable = true;
    # services.avahi = {
    #     enable = true;
    #     nssmdns = true;
    # };
  };

}
