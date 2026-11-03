{ ... }: {
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = false;
    };

    timeout = 3;
  };

  boot.tmp.cleanOnBoot = true;
}