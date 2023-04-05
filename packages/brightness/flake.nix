{
  description = "A CLI wrapper of nixpkgs.light";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: let
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
      brightness = pkgs.callPackage ./brightness.nix {};
      default = self.packages.${system}.brightness;
    });

    nixosModules.brightness = ({ pkgs, ... }: {
      programs.light.enable = true;

      nixpkgs.overlays = [
        (final: prev: {
          brightness = final.callPackage ./brightness.nix {};
        })
      ];

      home-manager.sharedModules = [
        ({ config, lib, pkgs, ... }: let
          cfg = config.programs.brightness;
        in {
          options.programs.brightness = {
            enable = lib.mkEnableOption "Whether to enable Brightness";
            step = lib.mkOption {
              type = lib.types.int;
              description = "The amound brightness will be increased or decreased.";
              default = 5;
            };
            onChange = lib.mkOption {
              type = lib.types.lines;
              description = "Bash script executed when brightness increases or decreases";
              default = ''echo "changed $1"'';
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = with pkgs; [
              brightness
            ];

            xdg.configFile."brightness/init" = {
              executable = true;
              text = ''
                export step=${toString cfg.step}
              '';
            };

            xdg.configFile."brightness/on-change" = {
              executable = true;
              text = cfg.onChange;
            };
          };
        })
      ];
    });

  };
}
