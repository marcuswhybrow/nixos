{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      modules = systemModules ++ [
        ({ lib, pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          networking.hostName = hostname; 
          networking.networkmanager.enable = lib.mkDefault true;
          nixpkgs.overlays = [
            (final: prev: {
              custom = inputs.self.packages.${pkgs.system};
            })
          ];
        })
        ./modules/intel-accelerated-video-playback.nix
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
      fish = pkgs.callPackage ./pkgs/fish.nix {};
      starship = pkgs.callPackage ./pkgs/starship.nix {};
      brightness = pkgs.callPackage ./pkgs/brightness.nix {};
      volume = pkgs.callPackage ./pkgs/volume.nix {};
      networking = pkgs.callPackage ./pkgs/networking.nix {};
      logout = pkgs.callPackage ./pkgs/logout.nix {};
    };
  });
}
