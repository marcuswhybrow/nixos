{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = outputs: let
    inherit (builtins) mapAttrs;
    inherit (outputs.nixpkgs.lib) nixosSystem;

    toNixosSystem = hostname: configFn: let
      nullConfig = configFn null;
      pkgs = import outputs.nixpkgs {
        inherit (nullConfig) system;
        config.allowUnfree = nullConfig.allowUnfree;
      };
      config = configFn pkgs;
    in nixosSystem {
      inherit (config) system;

      modules = [
        ./system/system.nix
        ./system/hardware.nix
        ./system/kernel.nix
        ./system/filesystem.nix
        ./system/boot.nix
        ./system/networking.nix
        ./system/localisation.nix
        ./system/gui.nix
        ./system/users.nix
        ./themes
        ./home-manager/git.nix
        ./home-manager/sway.nix
        ./home-manager/waybar.nix
        ./home-manager/neovim.nix
        ./home-manager/rofi.nix
        ./home-manager/alacritty.nix
        ./home-manager/audio.nix
        ./home-manager/display.nix
        outputs.home-manager.nixosModules.home-manager
        {
          config.nixpkgs = {
            hostPlatform = config.system;
            config.allowUnfree = config.allowUnfree;
          };
        }
        { networking.hostName = hostname; }
        { custom = removeAttrs config [ "pkgs" "system" "allowUnfree" "extraConfig" ]; }
        config.extraConfig
      ];
    };
  in {
    nixosConfigurations = mapAttrs toNixosSystem {
      marcus-laptop = import ./marcus-laptop.nix outputs;
    };
  };
}
