{inputs, ...}: {
   imports = [
      inputs.wrappers.flakeModules.wrappers
  #
  #   # currently unused
      inputs.flake-parts.flakeModules.modules
   ];

  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      wrappersModules = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = {
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
