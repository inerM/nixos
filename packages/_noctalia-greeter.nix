{...}: {
  flake.nixosModules.noctalia-greeter = {
    pkgs,
    ...
  }: {
    services.displayManager.noctalia-greeter = {
      enable = true;

      settings = {
        keyboard.layout = "us";
        cursor.size = 20;
      };

      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
      };
    };
  };
}
