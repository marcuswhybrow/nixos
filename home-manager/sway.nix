{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs replaceStrings;
  inherit (import ../utils { inherit lib; }) escapeDoubleQuotes;

  # https://i3wm.org/docs/userguide.html#exec
  exec = command: ''exec "${escapeDoubleQuotes command}"'';
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

          output."*" = {
            background = "#FFFFFF solid_color";
          };
          colors = {
            focused = {
              border = "#ff0000";
              background = "#ff0000";
              text = "#000000";
              indicator = "#ff0000";

              # The border of the app with input focus
              childBorder = "#666666";
            };
            focusedInactive = {
              border = "#ffffff";
              background = "#ffffff";
              text = "#000000";
              indicator = "#0000ff";
              # The border of the app in an inactive group that will
              # be selected first
              childBorder = "#eeeeee"; 
            };
            unfocused = {
              border = "#ffffff";
              background = "#ffffff";
              text = "#000000";
              indicator = "#00ff00";

              # The border of all other apps
              childBorder = "#ffffff";
            };
          };

          gaps = {
            smartBorders = "on";
            smartGaps = true;
            inner = 5;
          };


          # Home Manager does not support swhkd (Simple Wayland HotKey Daemon)
          # So using Sway keybindings instead
          # Honours command options defined in ../audio.nix
          keybindings = lib.mkOptionDefault (with config.custom; {
            XF86AudioMute = exec audio.mute;
            XF86AudioLowerVolume = exec audio.lowerVolume;
            XF86AudioRaiseVolume = exec audio.raiseVolume;
            XF86AudioPrev = exec audio.prev;
            XF86AudioPlay = exec audio.play;
            XF86AudioNext = exec audio.next;
            XF86MonBrightnessUp = exec display.brightness.up;
            XF86MonBrightnessDown = exec display.brightness.down;
          });
        };
      };
    }) config.custom.users;
  };
}
