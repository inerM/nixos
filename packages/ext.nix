{ self, ... }:

{
  flake.nixosModules.ext-service = { pkgs, ... }: let
  modules = with self.nixosModules; [
      nixsettings
      ];

  in {

    imports = modules;
    services.upower.enable = true;
    programs.wshowkeys.enable = true;    
    services.power-profiles-daemon.enable = true;
    services.udev.packages = [ pkgs.brightnessctl ];
    services.dbus.enable = true;
    security.polkit.enable = true;
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  
    services.udisks2.enable = true; # mount USB drives
    services.gvfs.enable = true;    # trash, network mounts in file managers
    programs.obs-studio.enable = true;
    
    environment.systemPackages = [
        pkgs.slurp
        pkgs.grim
        pkgs.libnotify
        pkgs.wl-clipboard
    ];
    # services.printing.enable = true;
    # services.avahi = {
    #     enable = true;
    #     nssmdns = true;
    # };
  };

}
