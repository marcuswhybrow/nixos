{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf;
  inherit (import ../utils { inherit lib; }) forEachUser options;
in {
  options.custom.users = options.mkForEachUser {
    rofi = {
      enable = mkEnableOption "Enable Rofi launcher";
    };
  };

  config = {
    home-manager.users = forEachUser config (user: {
      programs.rofi = mkIf user.rofi.enable {
        enable = true;
      };
    });
  };
}
