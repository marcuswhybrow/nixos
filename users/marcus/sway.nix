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
        menu = ''${pkgs.rofi}/bin/rofi -show drun -i -drun-display-format {name} -theme-str 'entry { placeholder: "Launch"; }' '';

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

        keybindings = let
          screenshotNotification = ''${pkgs.dunst}/bin/dunstify --appname screenshot --urgency low --timeout 500 Screenshot'';
        in lib.mkOptionDefault {
          "${modifier}+Escape" = ''exec ${pkgs.logout}/bin/logout'';
          XF86AudioMute = ''exec ${pkgs.volume}/bin/volume toggle-mute'';
          XF86AudioLowerVolume = ''exec ${pkgs.volume}/bin/volume down'';
          XF86AudioRaiseVolume = ''exec ${pkgs.volume}/bin/volume up'';
          # XF86AudioPrev = ''exec'';
          # XF86AudioPlay = ''exec'';
          # XF86AudioNext = ''exec'';
          XF86MonBrightnessUp = ''exec ${pkgs.brightness}/bin/brightness up'';
          XF86MonBrightnessDown = ''exec ${pkgs.brightness}/bin/brightness down'';
          "Print" = ''exec "${screenshotNotification}; ${pkgs.sway-contrib.grimshot}/bin/grimshot save output"'';
          "Mod4+B" = ''exec ${pkgs.brave}/bin/brave'';
          "Mod4+D" = ''exec "${pkgs.alacritty}/bin/alacritty --working-directory ~/.dotfiles --command vim .'';
        };
      };

      extraConfigEarly = ''
        # Automatically float
        for_window [class="mpv"] floating enable
        for_window [class="feh"] floating enable
      '';

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
