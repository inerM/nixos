{ inputs, ... }:
{
  flake.nixosModules.preservation = { config, lib, ... }:
    let
      persist = "/persist";

      normalUsers = lib.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users);
    in
    {
      imports = [ inputs.preservation.nixosModules.default ];

      options.my.persist = {
        homeDirectories = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ ];
          description = "Dirs under all user's home lives.";
        };
        homeFiles = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [ ];
          description = "Files under all user's home lives.";
        };
      };

      config = {
        boot.initrd.systemd.enable = true;
        fileSystems.${persist}.neededForBoot = true;

	systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service"];
	# environment.etc."machine-id".source = "/persist/etc/machine-id";

        my.persist = { 
        homeDirectories = [
          ".nixos"
          "Projects"
          "Downloads"
          "Documents"
          "Pictures"
          "Videos"
          "Music"
          {
            directory = ".ssh";
            mode = "0700";
          }
          # {
          #   directory = ".gnupg";
          #   mode = "0700";
          # }
          ".config"
          ".local/share"
          ".local/state"
        ];
        homeFiles = [ 
       
        ];
        };

        preservation = {
          enable = true;

          preserveAt.${persist} = {
            directories =
              [
                "/var/lib/nixos"
                "/var/lib/systemd"
                "/var/log"
              ]
              ++ lib.optionals config.networking.networkmanager.enable [
                "/etc/NetworkManager/system-connections"
              ]
              ++ lib.optional config.networking.wireless.iwd.enable "/var/lib/iwd"
              ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
              ++ lib.optional config.services.printing.enable "/var/lib/cups"
              ++ lib.optional config.services.openssh.enable "/etc/ssh";

            files = [
              {
                file = "/etc/machine-id";
                inInitrd = true;
              }
            ];

            users = lib.genAttrs normalUsers (_: {
              directories = config.my.persist.homeDirectories;
              files = config.my.persist.homeFiles;
            });
          };
        };
      };
    };
}
