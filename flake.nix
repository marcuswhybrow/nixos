{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cheeky-scripts.url = "github:marcuswhybrow/cheeky-scripts";
  };

  outputs = inputs: {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit hostname inputs;
        inherit (inputs.nixpkgs.lib) types;
        helpers = import ./helpers.nix inputs.nixpkgs.lib;
      };

      modules = systemModules ++ [
        ({ config, hostname, lib, types, pkgs, helpers, ... }: {
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
            ];
          };
          nixpkgs.overlays = [
            (final: prev: {
              # Allows cherry picking of unstable packages with `pkgs.unstable`
              unstable = import inputs.nixpkgs-unstable { inherit (final) system; };

              custom = inputs.self.packages.${pkgs.system};
            })
          ];
        })
        ./systems/options/dwl.nix
        ./systems/options/intel-accelerated-video-playback.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.cheeky-scripts.nixosModules.cheeky-scripts
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
  } // inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in {
    packages = {
      neovim = pkgs.callPackage ./pkgs/neovim.nix {};
      alacritty = pkgs.callPackage ./pkgs/alacritty.nix {};
      private = pkgs.callPackage ./pkgs/private.nix {};
      waybar = pkgs.callPackage ./pkgs/waybar.nix {};
      git = pkgs.callPackage ./pkgs/git.nix {};
      rofi = pkgs.callPackage ./pkgs/rofi.nix {};
      dunst = pkgs.callPackage ./pkgs/dunst.nix {};
      sway = pkgs.callPackage ./pkgs/sway.nix {};
    };
    apps.neovim = { type = "app"; program = "${inputs.self.packages.${pkgs.system}.neovim}/bin/vim"; };
    apps.sway = { type = "app"; program = "${inputs.self.packages.${pkgs.system}.sway}/bin/sway"; };
  });
}
