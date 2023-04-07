{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    programs.alacritty = {
      enable = true;
      firaCodeNerdFont = true;

      # https://github.com/alacritty/alacritty/blob/v0.11.0/alacritty.yml
      settings = {
        window.padding = lib.mkDefault { x = 10; y = 10; };
        window.opacity = lib.mkDefault 0.95;
      };
    };
  };
}
