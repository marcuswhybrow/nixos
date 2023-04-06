{
  description = "A systemctl wrapper to toggle user services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: let
    packageName = "toggle";
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      ${packageName} = pkgs.callPackage ./${packageName}.nix {};
      default = self.packages.${system}.${packageName};
    });

    nixosModules.${packageName} = ({ pkgs, ... }: {

      nixpkgs.overlays = [ (final: prev: { ${packageName} = final.callPackage ./${packageName}.nix {}; }) ];

      home-manager.sharedModules = [
        ({ config, lib, pkgs, ... }: let
          cfg = config.programs.${packageName};
        in {
          options.programs.${packageName} = {
            enable = lib.mkEnableOption "Whether to enable Toggle";
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ pkgs.${packageName} ];
          };
        })
      ];
    });

  };
}