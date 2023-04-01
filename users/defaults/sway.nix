[
  ({ config, lib, pkgs, helpers, ... }: {
    options.custom.users = helpers.options.mkForEachUser {
      sway.enable = lib.mkEnableOption "Enable sway window manager";
      sway.terminal = lib.mkOption { type = lib.types.str; };
      sway.disableBars = lib.mkOption { type = lib.types.bool; default = false; };
    };

    config.home-manager.users = helpers.config.mkForEachUser config (user: {
      home.packages = with pkgs; [ wlogout ];
      wayland.windowManager.sway = {
        inherit (user.sway) enable;
        config = {
          bars = lib.mkIf user.sway.disableBars [];
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
            "Mod1+Escape" = helpers.bash.exec ''fish -c "@logout"'';
          });
        };
      };
    });
  })
]
