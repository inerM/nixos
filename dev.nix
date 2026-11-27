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

    mk = label: color: attrs:
      pkgs.mkShell ({DEVSHELL_NAME = "${label}/${color}";} // attrs);
      
in {
  devShells = {
    default = mk "dev"    "green"   {packages = nixTools ++ pythonTools ++ phoneTools ++ rustTools;};
    nixos   = mk "nixos"  "blue"    {packages = nixTools;};
    phone   = mk "phone"  "magenta" {packages = phoneTools;};
    python  = mk "python" "yellow"  {packages = pythonTools;};
    rust    = mk "rust"   "red"     {
      packages = rustTools;
      nativeBuildInputs = [pkgs.pkg-config];
      buildInputs = [pkgs.openssl];
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };
    };
  };
}
