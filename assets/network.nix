{ ... }: {
  flake.nixosModules.network-service = { pkgs, ... }: {
    networking.networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    networking.modemmanager.enable = false;

    systemd.services.NetworkManager-wait-online.enable = false;


    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNS = [ "1.1.1.1" "9.9.9.9" "8.8.8.8" ];
        FallbackDNS = [ "1.0.0.1" "149.112.112.112" "8.8.4.4" ];
        Domains = [ "~." ];
        DNSOverTLS = "opportunistic";
        DNSSEC = "allow-downgrade";
        MulticastDNS = "no";
      };
    };

    environment.systemPackages = with pkgs; [
      proton-vpn
      wifitui
      networkmanager
    ];
  };
}
