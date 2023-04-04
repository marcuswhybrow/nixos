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
      onChange = { volume, isMuted }: ''
        dunstify \
          --appname changeVolume \
          --urgency low \
          --timeout 2000 \
          --icon audio-volume-$([[ ${isMuted} == true ]] && echo "muted" || echo "high") \
          --hints string:x-dunst-stack-tag:volume \
          $([[ ${isMuted} == false ]] && echo "--hints int:value:${volume}") \
          "$([[ ${isMuted} == false ]] && echo 'Volume: ${volume}%' || echo 'Volume Muted')"
      '';
    };

    programs.brightness = {
      enable = true;
      onChange = { brightness }: ''
        val=`light -G`
        dunstify \
          --appname changeBrightness \
          --urgency low \
          --hints string:x-dunst-stack-tag:brightness \
          --hints int:value:${brightness} \
          --timeout 1000 \
          "Brightness ${brightness}%"
      '';
    };

    wayland.windowManager.sway = {
      enable = true;
      
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
            "--release Super_L" = ''exec ${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Apps'';

            "${modifier}+Right" = "focus right";
            "${modifier}+Left" = "focus left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Escape" = "kill";

            XF86AudioMute = ''exec toggle-mute'';
            XF86AudioLowerVolume = ''exec volume down'';
            XF86AudioRaiseVolume = ''exec volume up'';

            XF86MonBrightnessUp = ''exec brightness up'';
            XF86MonBrightnessDown = ''exec brightness down'';

            "${modifier}+Shift+Escape" = ''exec swaynag -t warning -m "Shutdown?" -b "Shutdown" "systemctl poweroff"'';
            "Mod1+Control+Shift+Escape" = "mode default";
          };
        };
      };
    };
  };
}
