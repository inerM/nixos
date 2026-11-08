{ ... }:
{
   flake.nixosModules.app-files = { pkgs, ... }: {
   	environment.systemPackages = with pkgs; [ 
#        nautilus 
        zathura 
        imv
        vlc
       ];
   };
}   
