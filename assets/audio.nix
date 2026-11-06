{
   flake.nixosModules.audio-service = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        wiremix
        alsa-utils
      ];
	services.pulseaudio.enable = false;
   	security.rtkit.enable = true;
    	services.pipewire = {
      	  enable = true;
      	  alsa.enable = true;
          alsa.support32Bit = true;
    	  pulse.enable = true;
    	  wireplumber.enable = true;
    	};
      };
}
