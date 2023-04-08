{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cheeky-scripts = {
      url = "github:marcuswhybrow/cheeky-scripts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit hostname inputs;
        inherit (inputs.nixpkgs.lib) types;
        helpers = import ./helpers.nix inputs.nixpkgs.lib;
      };
      modules = systemModules ++ [
        ({ config, hostname, lib, types, helpers, ... }: {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          networking = {
            hostName = hostname; 
            networkmanager.enable = lib.mkDefault true;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit hostname inputs helpers types;
            };
            sharedModules = [
              { home.stateVersion = config.system.stateVersion; }
              ./users/options/git.nix
              ./users/options/waybar.nix
              ./users/options/alacritty.nix
              ./users/options/sway.nix
              ./users/options/rofi.nix
              ./users/options/dunst.nix
            ];
          };
        })
        ./systems/options/dwl.nix
        ./systems/options/intel-accelerated-video-playback.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.cheeky-scripts.nixosModules.allScripts
      ];
    }) {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus
        ./users/anne.nix
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./users/anne.nix
        ./users/marcus
      ];
    };
  };
}
