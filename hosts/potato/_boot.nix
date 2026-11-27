{ pkgs, ... }:
let
  grubTheme = pkgs.writeTextDir "theme.txt" ''
    title-text: ""
    desktop-color: "#000000"

    + label {
      text = "Select Operating System"
      left = 0
      top = 29%
      width = 100%
      align = "center"
      color = "#DBDEDA"
    }

    + boot_menu {
      left = 23%
      top = 35%
      width = 54%
      height = 22%
      item_color = "#A5AAA5"
      selected_item_color = "#FFFFFF"
      item_height = 22
      item_spacing = 2
      item_padding = 0
      icon_width = 0
      icon_height = 0
      item_icon_space = 0
      scrollbar = false
    }

    + label {
      id = "__timeout__"
      text = "%ds remaining"
      left = 0
      top = 59%
      width = 100%
      align = "center"
      color = "#92958E"
    }

    + label {
      text = "Enter  Boot    Up/Down  Select    e  Edit    c  Console"
      left = 0
      top = 64%
      width = 100%
      align = "center"
      color = "#92958E"
    }
  '';
in {
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = false;
      gfxmodeBios = "auto";
      splashImage = null;
      theme = grubTheme;
    };

    timeout = 6;
  };

  boot.tmp.cleanOnBoot = true;
}
