{ ... }: {


  flake.nixosModules.nixsettings = { ... }: {
    
    system.stateVersion = "26.05";

    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # deletes old generations automatically
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
