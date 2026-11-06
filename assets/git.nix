{
    flake.nixosModules.app-git = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.git ];
    };
}
