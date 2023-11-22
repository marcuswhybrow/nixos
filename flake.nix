{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;
    inherit (builtins) mapAttrs readDir;
    inherit (lib.attrsets) mapAttrs' mapAttrsToList filterAttrs;

    overlayCustomPkgs = pkgs: final: prev: {
      custom = mapAttrs' (n: v: {
        name = lib.strings.removeSuffix ".nix" n;
        value = pkgs.callPackage (./pkgs + "/${n}") {};
      }) (readDir ./pkgs);
    };

    toNixosSystem = hostname: systemModules: lib.nixosSystem (let 
      deriveHostnameModule = { lib, ... }: {
        networking.hostName = hostname; 
        networking.networkmanager.enable = lib.mkDefault true;
      };
      customPkgsModule = { pkgs, ... }: {
        nixpkgs.overlays = [(overlayCustomPkgs pkgs)];
      };
    in {
      modules = [
        ./modules/nix-flake-support.nix
        deriveHostnameModule
        customPkgsModule
        ./modules/intel-accelerated-video-playback.nix
      ] ++ systemModules;
    });
  in {
    nixosConfigurations = mapAttrs toNixosSystem {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus
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

    packages = let 
      pkgs = import "${inputs.nixpkgs}" (let 
        users = readDir ./users;
        userModule = name: import (./users + "/${name}") { 
          pkgs = inputs.nixpkgs; 
        };
        userOverlays = name: (userModule name).nixpkgs.overlays;
        overlaysForAllusers = mapAttrsToList (n: v: userOverlays n) users;
        concat = x: lib.lists.foldl (a: b: a ++ b) [] x;
        finalOverlays = concat overlaysForAllusers;
      in {
        system = "x86_64-linux";
        overlays = [(overlayCustomPkgs "${inputs.nixpkgs}")] ++ finalOverlays;
      });

      marcusOutputs = let 
        marcusFiles = readDir ./users/marcus;
        ignoreDefaultNix = filterAttrs (n: v: n != "default.nix");
        marcusPkgs = ignoreDefaultNix marcusFiles;

        callPackages = name: value: {
          name = lib.strings.removeSuffix ".nix" name;
          value = pkgs.callPackage (./users/marcus + "/${name}") {};
        };
      in mapAttrs' callPackages marcusPkgs;

      rawOutputs.private =  pkgs.callPackage ./pkgs/private.nix {};
    in
      marcusOutputs // rawOutputs;
  };
}
