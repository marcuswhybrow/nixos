{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations = builtins.mapAttrs (hostname: systemModules: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit hostname inputs;
        helpers = import ./helpers.nix inputs.nixpkgs.lib;
      };
      modules = systemModules ++ [
        ./systems/options/enforced-on-all-systems.nix
        ./systems/options/dwl.nix
        ./systems/options/intel-accelerated-video-playback.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.sharedModules = [
            ./users/options/brightness.nix
            ./users/options/git.nix
            ./users/options/logout.nix
            ./users/options/networking.nix
            ./users/options/systemctl-toggle.nix
            ./users/options/theme-light.nix
            ./users/options/volume.nix
            ./users/options/waybar-marcusbar.nix
          ];
        }
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
  };
}
