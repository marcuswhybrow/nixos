{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types;
  inherit (builtins) mapAttrs;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.sway = {
      enable = mkEnableOption "Enable sway window manager";
      terminal = mkOption { type = types.str; };
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      wayland.windowManager.sway = {
        inherit (userConfig.sway) enable;
        config = {
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
