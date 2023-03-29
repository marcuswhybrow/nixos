{ nixpkgs, home-manager }: let
  inherit (builtins) mapAttrs;
  inherit (nixpkgs.lib) nixosSystem;

  toNixosSystem = hostname: config: nixosSystem {
    inherit (config) system;

    modules = [
      ../system.nix
      ../hardware.nix
      ../kernel.nix
      ../filesystem.nix
      ../boot.nix
      ../networking.nix
      ../localisation.nix
      ../audio.nix
      ../display.nix
      ../gui.nix
      ../users.nix
      ../themes
      ../home-manager/git.nix
      ../home-manager/sway.nix
      ../home-manager/waybar
      ../home-manager/neovim.nix
      ../home-manager/rofi.nix
      ../home-manager/alacritty.nix
      home-manager.nixosModules.home-manager
      {
        config.nixpkgs = {
          hostPlatform = config.system;
          config.allowUnfree = config.allowUnfree;
        };
      }
      { custom = removeAttrs config [ "pkgs" "system" ]; }
      { custom.networking.hostName = hostname; }
    ];
  };
in {
  mkSystems = systemConfigs: {
    nixosConfigurations = mapAttrs toNixosSystem systemConfigs;
  };
}
