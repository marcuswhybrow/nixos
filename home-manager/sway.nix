{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs replaceStrings;
  inherit (import ../utils { inherit lib; }) escapeDoubleQuotes options forEachUser;

  # https://i3wm.org/docs/userguide.html#exec
  exec = command: ''exec "${escapeDoubleQuotes command}"'';
in {
  options.custom.users = options.mkForEachUser {
    sway = {
      enable = mkEnableOption "Enable sway window manager";
      terminal = mkOption { type = types.str; };
      disableBars = mkOption { type = types.bool; default = false; };
    };
  };


  config = {
    home-manager.users = forEachUser config (user: {
      home.packages = with pkgs; [
        wlogout
      ];
      wayland.windowManager.sway = {
        inherit (user.sway) enable;
        config = {
          bars = mkIf user.sway.disableBars [];
          menu = "${pkgs.rofi}/bin/rofi -show drun";
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
    });
  };
}
