{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs replaceStrings;
  utils = import ../utils { inherit lib; };
in {
  options.custom.users = utils.options.mkForEachUser {
    sway = {
      enable = mkEnableOption "Enable sway window manager";
      terminal = mkOption { type = types.str; };
      disableBars = mkOption { type = types.bool; default = false; };
    };
  };


  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      home.packages = with pkgs; [
        wlogout
      ];
      wayland.windowManager.sway = {
        inherit (user.sway) enable;
        config = {
          bars = mkIf user.sway.disableBars [];
          menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Launch";
          inherit (user.sway) terminal;
          input."*" = {
            repeat_delay = "300";
            xkb_layout = "gb";
            natural_scroll = "enabled";
            tap = "enabled";
          };

          gaps = {
            smartBorders = "on";
            smartGaps = true;
            inner = 5;
          };

          keybindings = lib.mkOptionDefault (with config.custom; {
            "Mod1+Escape" = utils.exec ''fish -c "@logout"'';
          });
        };
      };
    });
  };
}
