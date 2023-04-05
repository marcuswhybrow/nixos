{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    networking.url = "./packages/networking";
    brightness.url = "./packages/brightness";
  };

  outputs = inputs: let
    helpers = import ./helpers.nix inputs.nixpkgs.lib;
  in {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit hostname inputs helpers;
      };
      modules = systemModules ++ [
        ({ config, hostname, lib, helpers, ... }: {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          networking = {
            useDHCP = lib.mkDefault true;
            hostName = hostname; 
            networkmanager.enable = lib.mkDefault true;
            firewall.enable = lib.mkDefault true;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit hostname inputs helpers;
              inherit (inputs.nixpkgs.lib) types;
            };
            sharedModules = [
              { home.stateVersion = config.system.stateVersion; }
              ./users/options/git.nix
              ./users/options/logout.nix
              ./users/options/systemctl-toggle.nix
              ./users/options/theme-light.nix
              ./users/options/volume.nix
              ./users/options/waybar-marcusbar.nix
            ];
          };
        })
        ./systems/options/dwl.nix
        ./systems/options/intel-accelerated-video-playback.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.networking.nixosModules.networking
        inputs.brightness.nixosModules.brightness
      ];
    }) {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus.nix
        ./users/anne.nix
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./users/anne.nix
        ./users/marcus.nix
      ];
    };
  };
}
