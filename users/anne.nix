{ pkgs, lib, ... }: {
  users.users.anne = {
    description = "Anne Whybrow";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;
  };

  home-manager.users.anne = {
    home.packages = with pkgs; [
      brave
      pcmanfm
    ];

    themes.light.enable = true;

    programs.alacritty = {
      enable = true;
      settings.window.padding = { x = 5; y = 5; };
    };

    programs.rofi.enable = true;

    programs.fish = {
      enable = true;
      loginShellInit = ''sway'';
    };

    programs.starship.enable = true;

    programs.volume = {
      enable = true;
      onChange = ''
        set vol (pamixer --get-volume)
        set mute (pamixer --get-mute)
        dunstify \
          --appname changeVolume \
          --urgency low \
          --icon audio-volume-(if test $mute = true; echo "muted"; else; echo "high"; end) \
          --hints string:x-dunst-stack-tag:volume \
          (if test $mute = false; echo "--hints int:value:$vol"; else; echo ""; end) \
          --timeout 2000 \
          (if test $mute = false; echo '"Volume: $vol%"'; else; echo '"Volume Muted"'; end)
      '';
    };

    programs.brightness = {
      enable = true;
      onChange = ''
        set val (light -G)
        dunstify \
          --appname changeBrightness \
          --urgency low \
          --hints string:x-dunst-stack-tag:brightness \
          --hints int:value:$val \
          --timeout 1000 \
          "Brightness $val%"
      '';
    };

    wayland.windowManager.sway = {
      enable = true;
      
      extraConfig = ''
        mode anne
        exec_always systemctl --user stop waybar
        exec brave
      '';

      config = rec {
        modifier = "Mod4"; # Super_L
        bars = [];
        menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Launch";
        terminal = "alacritty";

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

        keybindings = lib.mkOptionDefault {
          "${modifier}+Shift+a" = "mode anne";
        };

        modes = lib.mkOptionDefault {
          anne = {
            "--release Super_L" = ''exec ${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Apps'';

            "${modifier}+Right" = "focus right";
            "${modifier}+Left" = "focus left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Escape" = "kill";

            XF86AudioMute = ''exec fish -c "@volume toggle-mute"'';
            XF86AudioLowerVolume = ''exec fish -c "@volume down"'';
            XF86AudioRaiseVolume = ''exec fish -c "@volume up"'';

            XF86MonBrightnessUp = ''exec fish -c "@brightness up"'';
            XF86MonBrightnessDown = ''exec fish -c "@brightness down"'';

            "${modifier}+Shift+Escape" = ''exec swaynag -t warning -m "Shutdown?" -b "Shutdown" "systemctl poweroff"'';
            "Mod1+Control+Shift+Escape" = "mode default";
          };
        };
      };
    };
  };
}
