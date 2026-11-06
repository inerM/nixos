
{ ... }:
{
  flake.nixosModules.fs = { lib, config, ... }:
    let
      cfg = config.my.fs;
    in
    {
      options.my.fs = {
        diskDevice = lib.mkOption {
          type = lib.types.str;
          default = "/dev/disk/by-label/nixos";
          description = "Ext4 partition containing nix/, boot/, and retained data.";
        };

        diskFsType = lib.mkOption {
          type = lib.types.str;
          default = "ext4";
        };

        rootSize = lib.mkOption {
          type = lib.types.str;
          default = "2G";
          description = "Maximum tmpfs root size.";
        };

        bootDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional separate boot partition for UEFI.";
        };

        swapDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "/dev/disk/by-label/swap";
        };
      };

      config = {
        # Ephemeral root
        fileSystems."/" = lib.mkForce {
          device = "none";
          fsType = "tmpfs";
          options = [
            "defaults"
            "size=${cfg.rootSize}"
            "mode=755"
          ];
        };

        # Physical persistent partition
        fileSystems."/persist" = {
          device = cfg.diskDevice;
          fsType = cfg.diskFsType;
          options = [ "noatime" ];
          neededForBoot = true;
        };

        # Persistent Nix store and state
        fileSystems."/nix" = {
          device = "/persist/nix";
          fsType = "none";
          options = [ "bind" ];
          depends = [ "/persist" ];
          neededForBoot = true;
        };

        # Boot files
        fileSystems."/boot" =
          if cfg.bootDevice != null then {
            device = cfg.bootDevice;
            fsType = "vfat";
            options = [ "umask=0077" ];
          } else {
            device = cfg.diskDevice;#"/persist/boot";
            fsType = cfg.diskFsType;#"none";
            options = [ "noatime"
                        #"x-systemd.requires-mount-for=/persist"
                        #"bind"
                      ];
            noCheck = true;
            #depends = [ "/persist" ];
            neededForBoot = false;
          };

        # Optional swap partition
        swapDevices = lib.mkForce (
          lib.optional (cfg.swapDevice != null) {
            device = cfg.swapDevice;
          }
        );

        # GRUB compatibility with tmpfs root
        boot.loader.grub.copyKernels = lib.mkDefault true;
      };
    };
}
