[
  ({ pkgs, lib, ... }: {
    users.users.anne = {
      description = "Anne Whybrow";
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" ];
      shell = pkgs.fish;
    };

    custom.users.anne = {
      theme = "light";
      audio.volume.step = 5;
      display.brightness.step = 5;
      sway = {
        enable = true;
        terminal = "alacritty";
        disableBars = true;
      };
      waybar.enable = false;
    };

    home-manager.users.anne = {
      home.packages = with pkgs; [
        brave
        pcmanfm
      ];

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
    };
  })

  # Sway: simplified for a new user
  ({ config, lib, pkgs, ... }: {
    home-manager.users.anne = {
      wayland.windowManager.sway.config = rec {
        modifier = "Mod4"; # Super_L

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
      wayland.windowManager.sway.extraConfig = ''
        mode anne
        exec_always systemctl --user stop waybar
      '';
    };
  })
]
