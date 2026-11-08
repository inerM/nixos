{ lib, self, ... }: 
{
    flake.nixosModules.services = {
        imports = lib.attrValues
        (lib.filterAttrs (name: _: lib.hasSuffix "-service" name) self.nixosModules);
  };
}

