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
    musnix.url = "github:musnix/musnix";
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;
    mwpkgs = inputs.mwpkgs.packages.x86_64-linux;

    toNixosSystem = hostname: systemModules: lib.nixosSystem {
      modules = systemModules;
      specialArgs = { inherit inputs mwpkgs; };
    };

    mountMarcusDesktop = import ./modules/samba-mount.nix {
      local = "/mnt/marcus-desktop/local";
      remote = "//192.168.0.23/Local";
    };
  in {
    nixosConfigurations = builtins.mapAttrs toNixosSystem {
      marcus-laptop = [
        inputs.musnix.nixosModules.musnix
        ./systems/marcus-laptop.nix
        ./users/marcus.nix
        ./modules/intel-accelerated-video-playback.nix
        ./modules/coding-fonts.nix
        mountMarcusDesktop
      ];

      marcus-desktop = [
        inputs.musnix.nixosModules.musnix
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
