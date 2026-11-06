{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

    preservation.url = "github:nix-community/preservation";

    quickshell-config = {                                                 # linked to my repo
    	url = "git+https://codeberg.org/inerM/quickshell";     
	    flake = false;
    };
    nautilus-my-computer = {
      url = "github:yannmasoch/nautilus-my-computer?dir=packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    inherit (lib.fileset) toList fileFilter;

    isNixModule = file:
      file.hasExt "nix"
      && file.name != "flake.nix"
      && !lib.hasPrefix "_" file.name;

    importTree = path:
      toList (fileFilter isNixModule path);

    mkFlake = inputs.flake-parts.lib.mkFlake {inherit inputs;};
  in
    mkFlake {imports = importTree ./.;};
}
