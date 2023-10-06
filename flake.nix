{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (builtins) mapAttrs readDir;
    inherit (inputs.nixpkgs.lib) nixosSystem;
    inherit (inputs.nixpkgs.lib.lists) foldl;
    inherit (inputs.nixpkgs.lib.attrsets) mapAttrs' mapAttrsToList filterAttrs;
    inherit (inputs.nixpkgs.lib.strings) removeSuffix;
    inherit (inputs.flake-utils.lib) eachDefaultSystem;
    overlayCustomPkgs = pkgs: final: prev: {
      custom = mapAttrs' (n: v: {
        name = removeSuffix ".nix" n;
        value = pkgs.callPackage (./pkgs + "/${n}") {};
      }) (readDir ./pkgs);
    };
  in {
    nixosConfigurations = mapAttrs (hostname: systemModules: nixosSystem {
      modules = [

        ({ lib, pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          networking.hostName = hostname; 
          networking.networkmanager.enable = lib.mkDefault true;
          nixpkgs.overlays = [

            # I don't use home-manager. Instead I repackage each program I like
            # to use with a hardcoded config. I overlay them under an attribute
            # named custom, so that users can include them in their home 
            # pacakges.
            #
            # Some pacakges have optional arguments which a user can configure,
            # not by overriding, but by repackaging:
            #
            # marcus.neovim = pkgs.callPackage ./pkgs/neovim { /* args */ };
            #
            # By thinking of user configs for packages, as a new package 
            # entirely, it becomes portable and reusable.

            (overlayCustomPkgs pkgs)
          ];
        })

        ./modules/intel-accelerated-video-playback.nix

      ] ++ systemModules;

    }) {

      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus
        ./users/anne
      ];

      Marcus-Desktop = [
        inputs.nixos-wsl.nixosModules.wsl
        ./systems/marcus-desktop.nix
        ./users/marcus
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./users/anne
        ./users/marcus
      ];

    };

  } // eachDefaultSystem (system: let

    pkgs = import "${inputs.nixpkgs}" { 

      inherit system;

      # packages are a separate output to nixosConfigurations, but I'd like to 
      # include some of the same overlays as depencies of my custom packages.

      overlays = [(overlayCustomPkgs "${inputs.nixpkgs}")]
      ++ foldl (a: b: a ++ b) [] (mapAttrsToList (n: v: (import (./users + "/${n}") { 
        pkgs = inputs.nixpkgs; 
      }).nixpkgs.overlays) (readDir ./users));

    };

  in {

    # Because I've repackages all my favourite programs with hardcoded configs
    # (see above). I can expose them as outputs and run them from anywhere in
    # the world. e.g.
    #
    # nix run github:marcuswhybrow/.nixos#neovim

    packages = 
      mapAttrs' 
        (name: value: {
          name = removeSuffix ".nix" name;
          value = pkgs.callPackage (./users/marcus + "/${name}") {};
        })
        (filterAttrs (n: v: n != "default.nix") (readDir ./users/marcus))
      // {
          private = pkgs.callPackage ./pkgs/private.nix {};
      };


  });
}
