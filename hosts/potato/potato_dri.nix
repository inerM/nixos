{ ... }: {
  flake.nixosModules.potato_dri = { pkgs, ... }: {
  	
    boot.initrd.kernelModules = [ "i915" ];

    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
       intel-vaapi-driver
      ];
    };

    environment.systemPackages = with pkgs; [
      mesa
      vulkan-tools
    ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };
  };
}
