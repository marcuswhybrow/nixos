{
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = outputs: let
    lib = import ./lib outputs;
  in lib.mkSystems {
    marcus-laptop = import ./systems/marcus-laptop.nix outputs;
  };
}
