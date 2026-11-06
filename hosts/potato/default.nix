{
  self,
  inputs,
  ...
}: {
	flake.nixosConfigurations.potato = inputs.nixpkgs.lib.nixosSystem {
  	    modules = [
	    	self.nixosModules.potato
	    ];                                                         # it must be the primary user so he can manage hjem aspect.
	};
	
	flake.nixosModules.potato = { ... }: {              # my pc is literally not more than a potato so name yours with something good.
		
		imports = [
		    ./_hw.nix                  # imports the hardware-configuration.nix. imports as yours accordingly.
  		  ./_boot.nix
  		  ./_locale.nix                          # refers to readme for details 
  		]
  		++ (with self.nixosModules; [ 
	    	impermanence
        potato_dri                                         # old cpu drivers              # user
				ui      
				services

        primaryuser
        sops
				apps
				
    ]) ++ [
    inputs.sops-nix.nixosModules.sops
    ];
  
     networking.hostName = "potato";
  };
}
