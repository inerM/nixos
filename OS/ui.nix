{ self, ... }: {
	
	flake.nixosModules.ui = { pkgs, ... }: 
   let modules = with self.nixosModules; [
	      gtk
   	    fonts
	      ly
#				umbriel
#				noctalia
#				noctalia-greeter
      ];
   in {
   	imports = modules;
    
    programs.niri.enable = true;
    programs.niri.package =
    self.packages.${pkgs.stdenv.hostPlatform.system}.desktop;
 #   environment.systemPackages = [
  #    self.packages.${pkgs.stdenv.hostPlatform.system}.terminal ];

   };
}
