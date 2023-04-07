{ config, lib, pkgs, ... }: {
  config.environment.systemPackages = with pkgs; [
    swaybg
    wl-clipboard
  ];

  config.home-manager.users.marcus = {
    services.dunst.enable = true;
    programs.toggle.enable = false;
    programs.logout.enable = true;

    programs.brightness = {
      enable = true;
      onChange = ''
        ${pkgs.dunst}/bin/dunstify \
        --appname changeBrightness \
        --urgency low \
        --timeout 2000 \
        --hints string:x-dunst-stack-tag:brightness \
        --hints int:value:$brightness \
        "Brightness $brightness%"
      '';
    };

    programs.volume = {
      enable = true;
      onChange = ''
        ${pkgs.dunst}/bin/dunstify \
          --appname changeVolume \
          --urgency low \
          --timeout 2000 \
          --icon audio-volume-$([[ $isMuted == true ]] && echo "muted" || echo "high") \
          --hints string:x-dunst-stack-tag:volume \
          $([[ $isMuted == false ]] && echo "--hints int:value:$1") \
          "$([[ $isMuted == false ]] && echo "Volume: $volume%" || echo "Volume Muted")"
      '';
    };

    programs.rofi.enable = true;

    wayland.windowManager.sway = let
      modifier = "Mod1";
    in {
      enable = true;
      lightTheme = true;

      config = {
        inherit modifier;
        bars = [];
        terminal = "alacritty";
        menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -i -display-drun Launch";

        input."*" = {
          repeat_delay = "300";
          xkb_layout = "gb";
          natural_scroll = "enabled";
          tap = "enabled";
        };

        # https://unsplash.com/photos/wQLAGv4_OYs
        output."*".background = ''~/Downloads/wallpaper-inkwater.jpg fill'';

        gaps = {
          smartBorders = "off";
          smartGaps = false;
          inner = 10;
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+Escape" = ''exec ${pkgs.logout}/bin/logout'';
          XF86AudioMute = ''exec ${pkgs.volume}/bin/volume toggle-mute'';
          XF86AudioLowerVolume = ''exec ${pkgs.volume}/bin/volume down'';
          XF86AudioRaiseVolume = ''exec ${pkgs.volume}/bin/volume up'';
          # XF86AudioPrev = ''exec'';
          # XF86AudioPlay = ''exec'';
          # XF86AudioNext = ''exec'';
          XF86MonBrightnessUp = ''exec ${pkgs.brightness}/bin/brightness up'';
          XF86MonBrightnessDown = ''exec ${pkgs.brightness}/bin/brightness down'';
          "Mod4+S" = ''exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save active'';
        };
      };

      # Ordinarily waybar would lauch itself, but you can't do that if you want
      # to use "hide" mode so it appears only when holding the Sway modifier key.
      # https://github.com/Alexays/Waybar/wiki/Configuration
      # https://github.com/Alexays/Waybar/pull/1244
      extraConfig = ''
        bar {
          swaybar_command waybar
          mode hide
          hidden_state hide
          modifier ${modifier}
        }
      '';
    };
  };
}
