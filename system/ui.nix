{ self, ... }: {
	
	flake.nixosModules.ui = { pkgs, ... }: 
   let modules = with self.nixosModules; [
	      gtk
   	    fonts
	      ly
      ];
   in {
   	imports = modules;
    
    programs.niri.enable = true;
    programs.niri.package =
    self.packages.${pkgs.stdenv.hostPlatform.system}.desktop;

   };
}
