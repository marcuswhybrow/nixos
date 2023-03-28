{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.alacritty = {
      enable = mkEnableOption "Enable alacritty";
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      programs.alacritty = mkIf userConfig.alacritty.enable {
        enable = true;
        settings = {
          /*
          font = {
            normal.family = "";
            size = 11;
            bold = { style = "Bold"; };
            }; */

          window.padding = {
            x = 2;
            y = 2;
          };

          # https://github.com/alacritty/alacritty-theme/blob/c13db2aeff025f23155fdf297a45a47d8588a2f1/themes/atom_one_light.yaml
          colors = {
            primary = {
              background = "0xf8f8f8";
              foreground = "0x2a2b33";
            };
            normal = {
              black = "0x000000";
              red = "0xde3d35";
              green = "0x3e953a";
              yellow = "0xd2b67b";
              blue = "0x2f5af3";
              magenta = "0xa00095";
              cyan = "0x3e953a";
              white = "0xbbbbbb";
            };
            bright = {
              black = "0x000000";
              red = "0xde3d35";
              green = "0x3e953a";
              yellow = "0xd2b67b";
              blue = "0x2f5af3";
              magenta = "0xa00095";
              cyan = "0x3e953a";
              white = "0xffffff";
            };
          };
        };
      };
    }) config.custom.users;
  };
}
