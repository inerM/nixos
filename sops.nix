{
  flake.nixosModules.sops = {
    sops.defaultSopsFile = ./secrets/secrets.yaml;
    sops.age.keyFile = "/persist/sops/key.txt";
  };
}
