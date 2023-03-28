{ nixpkgs, home-manager }: {
  mkSystem = system: configFn: nixpkgs.lib.nixosSystem {
    inherit system;
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
      ../home-manager/git.nix
      ../home-manager/sway.nix
      ../home-manager/waybar
      ../home-manager/neovim.nix
      ../home-manager/rofi.nix
      ../home-manager/alacritty.nix
      home-manager.nixosModules.home-manager
      {
        config.nixpkgs = {
          hostPlatform = system;
          config.allowUnfree = true;
        };
      }
      {
        custom = (configFn (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }));
      }
    ];
  };
}
