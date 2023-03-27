{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.sway = {
      enable = mkEnableOption "Enable sway window manager";
      terminal = mkOption { type = types.str; };
      disableBars = mkOption { type = types.bool; default = false; };
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      wayland.windowManager.sway = {
        inherit (userConfig.sway) enable;
        config = {
          bars = mkIf userConfig.sway.disableBars [];
          menu = "${pkgs.rofi}/bin/rofi -show drun";
          inherit (userConfig.sway) terminal;
          input."*" = {
            repeat_delay = "300";
            xkb_layout = "gb";
            natural_scroll = "enabled";
            tap = "enabled";
          };
        };
      };
    }) config.custom.users;
  };
}
