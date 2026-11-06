{
   flake.nixosModules.bluetooth-service = { pkgs, ... }: {
      hardware.bluetooth = {
      	enable = true;
      	powerOnBoot = true;
      	settings.General.Experimental = true; # show device battery levels
      };
      environment.systemPackages = [ pkgs.bluetui ];
    };
}
