{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  utils = import ../utils { inherit lib; };
in {
  options.custom.users = utils.options.mkForEachUser {
    alacritty = {
      enable = mkEnableOption "Enable alacritty";
    };
  };

  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      programs.alacritty = {
        enable = user.alacritty.enable;
        settings = {
          window.padding = { x = 5; y = 5; };
        };
      };
    });
  };
}
