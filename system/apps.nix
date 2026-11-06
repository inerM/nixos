{ lib, self, ... }: {
  flake.nixosModules.apps = {
       imports = lib.attrValues
        (lib.filterAttrs (name: _: lib.hasPrefix "app-" name) self.nixosModules);
  };
}

