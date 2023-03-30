{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf;
  utils = import ../utils { inherit lib; };
in {
  options.custom.users = utils.options.mkForEachUser {
    rofi = {
      enable = mkEnableOption "Enable Rofi launcher";
    };
  };

  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      programs.rofi = mkIf user.rofi.enable {
        enable = true;
      };
    });
  };
}
