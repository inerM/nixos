{ ... }: {
  perSystem = { pkgs, ... }: let
    nixTools = with pkgs; [ alejandra nixd statix deadnix nvd ];
    phoneTools = with pkgs; [ android-tools scrcpy ];
    pythonTools = with pkgs; [
      (python3.withPackages (ps: [ ps.requests ps.rich ps.pytest ]))
      ruff
      uv
    ];
    rustTools = with pkgs; [
      cargo rustc rust-analyzer clippy rustfmt
    ];
  in {
    devShells = {
      default = pkgs.mkShell { packages = nixTools ++ pythonTools ++ phoneTools ++ rustTools; };
      nixos   = pkgs.mkShell { packages = nixTools; };
      phone   = pkgs.mkShell { packages = phoneTools; };
      python  = pkgs.mkShell { packages = pythonTools; };
      rust    = pkgs.mkShell {
        packages = rustTools;
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl ];
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };
    };
  };
}
