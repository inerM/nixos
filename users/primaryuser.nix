{ ... }: {
  flake.nixosModules.primaryuser = { config, ... }:
  {

    sops.secrets.user_password.neededForUsers = true;
    users.users.inerm = {     
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.user_password.path;
      description = "inert M";  
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
	      "audio"
	      "lp"
       ];
     };


    sops.secrets.root_password.neededForUsers = true;
    users.users.root.hashedPasswordFile  = config.sops.secrets.root_password.path;
   };
}
