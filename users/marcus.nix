[
  # Neovim
  ({ pkgs, ... }: {
    home-manager.users.marcus = {
      home.packages = [ pkgs.wl-clipboard ];
      programs.neovim = {
        enable = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          vim-fish
          vim-nix
        ];
      };
    };
  })

  # Wayland Window Manager testing
  ({ pkgs, ... }: {
    home-manager.users.marcus = {
      home.packages = with pkgs; [
        # Testing various tiling window managers
        cagebreak 
        river
        cardboard # scrolling wm
        #dwl foot # suckless
        # Hyperland requires nixos-unstable
        # github:jbuchermn/newm#newm
        #outputs.newm
        qtile
        # https://github.com/michaelforney/velox
        # https://github.com/inclement/vivarium
        # https://github.com/waymonad/waymonad
      ];

      xdg.configFile."river/init" = {
        text = ''
          #!/run/current-system/sw/bin/sh
          ${builtins.readFile (builtins.fetchurl {
            url = "https://raw.githubusercontent.com/riverwm/river/0.2.x/example/init";
            sha256 = "sha256:0dmk29gak0hqb6ghpzrqd15g0vmsk10wzkiw9qhz5l7gb0mfdsxf";
          })}
          riverctl map normal Super T spawn alacritty
        '';
        executable = true;
      };

      xdg.configFile."cardboard/cardboardrc" = {
        executable = true;
        text = ''
          #!/run/current-system/sw/bin/sh

          alias cutter=${pkgs.cardboard}/bin/cutter

          mod=alt

          cutter config gap 5
          cutter config focus_color 0 0 0

          cutter config mouse_mod $mod

          cutter bind $mod+shift+e quit
          cutter bind $mod+return exec alacritty


          cutter bind $mod+left focus left
          cutter bind $mod+right focus right
          
          cutter bind $mod+h focus left
          cutter bind $mod+l focus right


          cutter bind $mod+shift+left move -10 0
          cutter bind $mod+shift+right move 10 0
          cutter bind $mod+shift+up move 0 -10
          cutter bind $mod+shift+down move 0 10

          cutter bind $mod+shift+h move -10 0
          cutter bind $mod+shift+j move 0 10
          cutter bind $mod+shift+k move 0 -10
          cutter bind $mod+shift+l move 10 0

          cutter bind $mod+shift+p pop_from_column


          cutter bind $mod+shift+q close

          for i in $(seq 1 6); do
                  cutter bind $mod+$i workspace switch $(( i - 1 ))
                  cutter bind $mod+shift+$i workspace move $(( i - 1 ))
          done

          cutter bind $mod+shift+space toggle_floating
        '';
      };
    };
  })

  # Shell & Terminal
  ({ pkgs, ... }: {
    home-manager.users.marcus = {
      home.packages = with pkgs; [
        ranger
      ];
      programs.alacritty = {
        enable = true;
        settings.window.padding = { x = 5; y = 5; };
      };

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
    };
  })

  # The Basics
  ({ pkgs, ... }: {
    users.users.marcus = {
      description = "Marcus Whybrow";
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" ];
      shell = pkgs.fish;
    };

    custom.users.marcus = {
      theme = "light";
      git = { 
        enable = true;
        userName = "Marcus Whybrow";
        userEmail = "marcus@whybrow.uk";
      };
      sway = {
        enable = true;
        terminal = "alacritty";
        disableBars = true;
      };
      waybar.enable = true;
      audio.volume.step = 5;
      display.brightness.step = 5;
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
      ];
      
      programs.rofi.enable = true;
    };
  })
]
