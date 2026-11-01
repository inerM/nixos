{ ... }: {
  flake.nixosModules.primaryuser = {

    users.users.koesinn = {        # change user01 to to your username
      isNormalUser = true;
      initialPassword = "dihh";
   #   hashedPasswordFile = "/persist/passwords/dihh"; (only needed if impermanence opting)
      description = "Koesinn";   #change your YOURNAME to yours.
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
	      "audio"
	      "lp"
       ];
     };
  #  users.users.root.hashedPasswordFile  = "/persist/passwords/root";
   };
}
