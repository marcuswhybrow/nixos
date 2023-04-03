{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = outputs: let
    mkNixosSystems = systems: let
      mkNixosSystem = hostname: systemModuleListPaths: let
        allModuleListPaths = systemModuleListPaths ++ [
          ./modules/intel-accelerated-video-playback.nix
          ./systems/defaults/defaults.nix

          ./users/defaults/home-manager.nix
          ./users/defaults/audio.nix
          ./users/defaults/display.nix
          ./users/defaults/git.nix
          ./users/defaults/sway.nix
          ./users/defaults/waybar.nix
          ./users/defaults/themes.nix
        ];
        moduleLists = map (x: import x) allModuleListPaths;
      in outputs.nixpkgs.lib.nixosSystem {
        modules = (builtins.concatLists moduleLists) ++ [
          {
            _module.args = {
              inherit outputs hostname;
              helpers = import ./utils.nix outputs.nixpkgs.lib;
            };
          }
          outputs.home-manager.nixosModules.home-manager
        ];
      };
    in builtins.mapAttrs (mkNixosSystem) systems;
  in {
    nixosConfigurations = mkNixosSystems {
      marcus-laptop = [
        ./users/marcus.nix
        ./users/anne.nix
        ./systems/marcus-laptop.nix
      ];

      anne-laptop = [
        ./users/anne.nix
        ./users/marcus.nix
        ./systems/anne-laptop.nix
      ];
    };
  };
}
