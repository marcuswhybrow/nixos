{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      modules = [
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
       ] ++ systemModules;
    }) {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus.nix
        ./users/anne.nix
      ];

      Marcus-Desktop = [
        inputs.nixos-wsl.nixosModules.wsl
        ./systems/marcus-desktop.nix
        ./users/marcus.nix
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./users/anne.nix
        ./users/marcus.nix
      ];
    };
  } // inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import "${inputs.nixpkgs}" { inherit system; };
    callPackageForEach = pkgs.lib.attrsets.mapAttrs' (name: value: {
      name = pkgs.lib.strings.removeSuffix ".nix" name;
      value = pkgs.callPackage (./pkgs + "/${name}") {};
    });
  in {
    packages = callPackageForEach (builtins.readDir ./pkgs);
  });
}
