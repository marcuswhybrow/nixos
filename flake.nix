{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    inherit (import ./lib { inherit nixpkgs home-manager; }) mkSystems;
  in mkSystems {
    marcus-laptop = import ./systems/marcus-laptop.nix;
  };
}
