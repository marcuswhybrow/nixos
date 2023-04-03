{ config, lib, pkgs, ... }: {
  users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish;
  };

  home-manager.users.marcus = {
    home.packages = with pkgs; [
      # htop requires lsof when you press `l` on a process
      htop lsof

      brave
      vimb
      discord
      obsidian

      plex-media-player

      wl-clipboard
      ranger
    ];

    themes.light.enable = true;

    programs.fish = {
      enable = true;
      shellAbbrs = {
        c = ''vim ~/.dotfiles/systems/(hostname).nix'';
        d = ''cd ~/.dotfiles'';
        t = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d).md'';
        y = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d --date yesterday).md'';
      };
      functions = {
        timeline = ''
          set days (if set --query $argv[1]; echo $argv[1]; else; echo 0; end)
          vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d --date "$days days ago").md
        '';
      };
      loginShellInit = ''sway'';
    };

    programs.starship.enable = true;

    programs.alacritty = {
      enable = true;
      settings.window.padding = { x = 5; y = 5; };
    };

    programs.gh.enable = true;
    programs.git = {
      enable = true;
      userName = "Marcus Whybrow";
      userEmail = "marcus@whybrow.uk";
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-fish
        vim-nix
      ];
    };
    
    programs.rofi.enable = true;
    programs.logout.enable = true;
    programs.networking.enable = true;

    programs.volume = {
      enable = true;
      onChange = ''
        set vol (pamixer --get-volume)
        set mute (pamixer --get-mute)
        dunstify \
          --appname changeVolume \
          --urgency low \
          --timeout 2000 \
          --icon audio-volume-(if test $mute = true; echo "muted"; else; echo "high"; end) \
          --hints string:x-dunst-stack-tag:volume \
          (if test $mute = false; echo "--hints int:value:$vol"; else; echo ""; end) \
          (if test $mute = false; echo '"Volume: $vol%"'; else; echo '"Volume Muted"'; end)
      '';
    };

    programs.brightness = {
      enable = true;
      onChange = { brightness }: ''
        dunstify \
          --appname changeBrightness \
          --urgency low \
          --timeout 2000 \
          --hints string:x-dunst-stack-tag:brightness \
          --hints int:value:${brightness} \
          "Brightness ${brightness}%"
      '';
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      marcusBar = {
        enable = true;
        network.onClick = ''alacritty -c fish -c network'';
        cpu.onClick = ''alacritty -c htop --soft-key=PERCENT_CPU'';
        memory.onClick = ''alacritty -c htop --soft-key=PERCENT_MEM'';
        disk.onClick = ''alacritty -c htop --soft-key=IO_RATE'';
        logout.onClick = ''fish -c logout'';
      };
    };

    wayland.windowManager.sway = {
      enable = true;

      config = rec {
        modifier = "Mod1";
        bars = [];
        terminal = "alacritty";
        menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -display-drun Launch";

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
          "${modifier}+Escape" = ''exec fish -c "logout"'';
          "${modifier}+Shift+Escape" = ''exec fish -c "systemctl-toggle waybar"'';
          XF86AudioMute = ''exec fish -c "volume toggle-mute"'';
          XF86AudioLowerVolume = ''exec fish -c "volume down"'';
          XF86AudioRaiseVolume = ''exec fish -c "volume up"'';
          # XF86AudioPrev = ''exec'';
          # XF86AudioPlay = ''exec'';
          # XF86AudioNext = ''exec'';
          XF86MonBrightnessUp = ''exec brightness up'';
          XF86MonBrightnessDown = ''exec brightness down'';
        };
      };
    };
  };
}
