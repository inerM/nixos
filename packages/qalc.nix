{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.qalc = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.libqalculate;
      flags = {
      };
      appendFlag = [
        "-s"
        "autocalc"
        "-s"
        "decimal comma off"
      ];
    };
  };
}
