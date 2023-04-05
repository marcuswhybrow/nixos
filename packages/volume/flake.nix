{
  description = "A CLI wrapper of pamixer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: let
    packageName = "volume";
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

      nixpkgs.overlays = [
        (final: prev: {
          ${packageName} = final.callPackage ./${packageName}.nix {};
        })
      ];

      home-manager.sharedModules = [
        ({ config, lib, pkgs, ... }: let
          cfg = config.programs.${packageName};
        in {
          options.programs.${packageName} = {
            enable = lib.mkEnableOption "Whether to enable Volume CLI";
            step = lib.mkOption {
              type = lib.types.int;
              description = "The amount volume will be increase or decrease.";
              default = 5;
            };
            unmuteOnChange = lib.mkOption {
              type = lib.types.bool;
              description = "Whether volume change automatically unmutes.";
              default = true;
            };
            onChange = lib.mkOption {
              type = lib.types.lines;
              description = "Bash script executed when volume increases or decreases.";
              default = "";
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = with pkgs; [
              volume
            ];

            xdg.configFile."${packageName}/init" = {
              executable = true;
              text = ''
                export step=${toString cfg.step}
                export unmuteOnChange=${toString cfg.unmuteOnChange}
              '';
            };

            xdg.configFile."${packageName}/on-change" = {
              executable = true;
              text = ''
                volume="$1"; isMuted="$2"
                ${cfg.onChange}
              '';
            };
          };
        })
      ];
    });

  };
}
