{
  lib,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # My whole desktop in one package, includes kityy terminal
    packages.desktop = inputs.wrappers.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
      terminal = lib.getExe self'.packages.terminal;
      env = {
        EDITOR = lib.getExe self'.packages.helix;
      };
    };

    packages.terminal =
      (inputs.wrappers.wrappers.kitty.apply {
        inherit pkgs;
        imports = [self.wrappersModules.kitty];
        shell = lib.getExe self'.packages.environment;
      }).wrapper;

    packages.environment = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.fish;
      runtimePkgs = [

	      pkgs.nil
	      pkgs.nixd
	      pkgs.statix
	      pkgs.alejandra
	      pkgs.manix
	      pkgs.nix-inspect
        # other
        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.wget
        pkgs.killall
        pkgs.fzf
        pkgs.btop
        pkgs.eza
        pkgs.fd
        pkgs.zoxide
        pkgs.ripgrep
        pkgs.fastfetch
        pkgs.tree-sitter
        pkgs.ffmpeg
        pkgs.lazygit
	
        # wrapped
        self'.packages.nh
        self'.packages.helix
	      self'.packages.qalc
	      self'.packages.jujutsu
	      self'.packages.jjui	
      ];
      env = {
        EDITOR = lib.getExe self'.packages.helix;
      };
    };

  };

}
