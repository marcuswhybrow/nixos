{ pkgs, lib, ... }: {

  users.users.anne = {
    description = "Anne Whybrow";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      brave
      pcmanfm

      marcus.alacritty
      marcus.rofi
      marcus.dunst
    ];
  };

  home-manager.users.anne = let
    notify = "${pkgs.libnotify}/bin/notify-send";
  in {
    programs.fish = {
      enable = true;
      loginShellInit = ''sway'';
    };

    programs.starship.enable = true;

    programs.brightness = {
      enable = true;
      onChange = ''
        ${notify} \
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
        ${notify} \
          --appname changeVolume \
          --urgency low \
          --timeout 2000 \
          --icon audio-volume-$([[ $isMuted == true ]] && echo "muted" || echo "high") \
          --hints string:x-dunst-stack-tag:volume \
          $([[ $isMuted == false ]] && echo "--hints int:value:$volume") \
          "$([[ $isMuted == false ]] && echo "Volume: $volume%" || echo "Volume Muted")"
      '';
    };

    wayland.windowManager.sway = {
      enable = true;
      lightTheme = true;
      
      extraConfig = ''
        mode anne
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
            "--release Super_L" = ''exec ${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun -i Apps'';

            "${modifier}+Right"       = "focus right";
            "${modifier}+Left"        = "focus left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Left"  = "move left";
            "${modifier}+Escape"      = "kill";

            XF86AudioMute         = ''exec ${pkgs.volume}/bin/volume toggle-mute'';
            XF86AudioLowerVolume  = ''exec ${pkgs.volume}/bin/volume down'';
            XF86AudioRaiseVolume  = ''exec ${pkgs.volume}/bin/volume up'';
            XF86MonBrightnessUp   = ''exec ${pkgs.brightness}/bin/brightness up'';
            XF86MonBrightnessDown = ''exec ${pkgs.brightness}/bin/brightness down'';

            "${modifier}+Shift+Escape"  = ''exec swaynag -t warning -m "Shutdown?" -b "Shutdown" "systemctl poweroff"'';
            "Mod1+Control+Shift+Escape" = ''mode default'';
          };
        };
      };
    };
  };
}
