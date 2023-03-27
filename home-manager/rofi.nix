{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.rofi = {
      enable = mkEnableOption "Enable Rofi launcher";
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      programs.rofi = mkIf userConfig.rofi.enable {
        enable = true;
        font = "Droid Sans Mono 14";
      };
    }) config.custom.users;
  };
}
