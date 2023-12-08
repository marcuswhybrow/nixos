{
  inputs = {
    mwpkgs = {
      url = "github:marcuswhybrow/mwpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = { 
      url = "github:nix-community/NixOS-WSL"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;
    mwpkgs = inputs.mwpkgs.packages.x86_64-linux;

    toNixosSystem = hostname: systemModules: lib.nixosSystem {
      modules = systemModules;
      specialArgs = { inherit inputs mwpkgs; };
    };
  in {
    nixosConfigurations = builtins.mapAttrs toNixosSystem {
      marcus-laptop = [
        ./systems/marcus-laptop.nix
        ./users/marcus.nix
        ./modules/intel-accelerated-video-playback.nix
        ./modules/coding-fonts.nix
      ];

      marcus-desktop = [
        ./systems/marcus-desktop.nix
        ./users/marcus.nix
        ./modules/coding-fonts.nix
      ];

      anne-laptop = [
        ./systems/anne-laptop.nix
        ./modules/intel-accelerated-video-playback.nix
        ./users/anne.nix
        ./users/marcus.nix
      ];

    };
  };
}
