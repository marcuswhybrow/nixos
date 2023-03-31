outputs: let
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
      ../system.nix
      ../hardware.nix
      ../kernel.nix
      ../filesystem.nix
      ../boot.nix
      ../networking.nix
      ../localisation.nix
      ../gui.nix
      ../users.nix
      ../themes
      ../home-manager/git.nix
      ../home-manager/sway.nix
      ../home-manager/waybar.nix
      ../home-manager/neovim.nix
      ../home-manager/rofi.nix
      ../home-manager/alacritty.nix
      ../home-manager/audio.nix
      ../home-manager/display.nix
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
  mkSystems = systemConfigs: {
    nixosConfigurations = mapAttrs toNixosSystem systemConfigs;
  };
}
