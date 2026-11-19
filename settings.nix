{ ... }: {


  flake.nixosModules.nixsettings = { ... }: {
    
    system.stateVersion = "26.05";

    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
nix.settings = {
  extra-substituters = [
    "https://noctalia.cachix.org"
    "https://umbriel.cachix.org"
  ];

  extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
  ];
};

    # deletes old generations automatically
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
