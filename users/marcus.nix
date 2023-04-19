{ pkgs, ... }: let
  terminalPadding = 20;
  primaryColor = "#1e88eb";
in {
  nixpkgs.overlays = [
    (final: prev: {
      marcus = let
        alacritty = "${final.marcus.alacritty}/bin/alacritty";
      in {
        alacritty = prev.custom.alacritty.override {
          padding = terminalPadding;
          opacity = 0.95;
        };

        fish = prev.custom.fish.override {
          init = let
            nixos = "~/.nixos";
            config = "~/.config";
            obsidian = "~/obsidian/Personal";
          in ''
            if status is-login
              ${pkgs.dbus}/bin/dbus-run-session ${pkgs.marcus.sway}/bin/sway
            end

            if status is-interactive
              abbr --add d cd ${nixos}
              abbr --add c "cd ${nixos} && vim users/$(whoami).nix"
              abbr --add config cd ${config}

              abbr --add t vim ${obsidian}/Timeline/$(date +%Y-%m-%d).md
              abbr --add y vim ${obsidian}/Timeline/$(date +%Y-%m-%d --date yesterday).md

              abbr --add osswitch sudo nixos-rebuild switch
              abbr --add ostest sudo nixos-rebuild test

              abbr --add gs git status
              abbr --add ga git add .
              abbr --add gc git commit
              abbr --add gp git push
              abbr --add gd git diff

              ${pkgs.marcus.starship}/bin/starship init fish | source
            end
          '';

          functions.fish_greeting = ''echo (whoami) @ (hostname)'';
        };

        starship = prev.custom.starship.override {
          init = ''
            [[nix_shell]]
            heuristic = true
          '';
        };

        neovim = prev.custom.neovim.override {
          vimAlias = true;
          beforeNeovimOpens = ''
             ${alacritty} msg config \
              window.padding.x=0 \
              window.padding.y=0
            ${final.wtype}/bin/wtype -M ctrl 0
          '';
          afterNeovimCloses = ''
            ${alacritty} msg config \
              window.padding.x=${toString terminalPadding} \
              window.padding.y=${toString terminalPadding}
            ${final.wtype}/bin/wtype -M ctrl 0
          '';
        };

        waybar = prev.custom.waybar.override {
          inherit primaryColor;
          warningColor = "#ff8800";
          criticalColor = "#ff0000";
          iconFont = "Font Awesome 6 Free";
          extraConfig = let 
            openInAlacritty = "${alacritty} --command";
            htop = "${final.htop}/bin/htop";
            open = "${final.xdg-utils}/bin/xdg-open";
          in rec {
            network.on-click = ''${final.marcus.networking}/bin/networking'';
            wifiAlarm.on-click = network.on-click;
            cpu.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_CPU'';
            memory.on-click = ''${openInAlacritty} ${htop} --sort-key=PERCENT_MEM'';
            disk.on-click = ''${openInAlacritty} ${htop} --sort-key=IO_RATE'';
            date.on-click = ''${open} https://calendar.proton.me/u/1'';
          };
        };

        rofi = prev.custom.rofi.override {
          borderColor = primaryColor;
        };

        dunst = prev.custom.dunst.override {
          extraConfig.global = {
            dmenu = "${pkgs.marcus.rofi}/bin/rofi -show dmenu -p Notification";
            frame_color = primaryColor;
            foreground = primaryColor;
            highlight = primaryColor;
          };
        };

        sway = prev.custom.sway.override {
          replaceConfig = ''
            font pango:monospace 8.000000

            floating_modifier Mod1

            default_border pixel 2
            default_floating_border pixel 2
            hide_edge_borders none

            focus_wrapping no
            focus_follows_mouse yes
            focus_on_window_activation smart

            mouse_warping output

            workspace_layout default
            workspace_auto_back_and_forth no

            client.focused #ff0000 #ff0000 #000000 #ff0000 #ff441e
            client.focused_inactive #ffffff #ffffff #000000 #0000ff #ffffff00
            client.unfocused #ffffff #ffffff #000000 #00ff00 #dddddd
            client.urgent #2f343a #900000 #ffffff #900000 #900000
            client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
            client.background #ffffff

            bindsym Mod1+1 workspace number 1
            bindsym Mod1+2 workspace number 2
            bindsym Mod1+3 workspace number 3
            bindsym Mod1+4 workspace number 4
            bindsym Mod1+5 workspace number 5
            bindsym Mod1+6 workspace number 6
            bindsym Mod1+7 workspace number 7
            bindsym Mod1+8 workspace number 8
            bindsym Mod1+9 workspace number 9

            bindsym Mod1+Shift+1 move container to workspace number 1
            bindsym Mod1+Shift+2 move container to workspace number 2
            bindsym Mod1+Shift+3 move container to workspace number 3
            bindsym Mod1+Shift+4 move container to workspace number 4
            bindsym Mod1+Shift+5 move container to workspace number 5
            bindsym Mod1+Shift+6 move container to workspace number 6
            bindsym Mod1+Shift+7 move container to workspace number 7
            bindsym Mod1+Shift+8 move container to workspace number 8
            bindsym Mod1+Shift+9 move container to workspace number 9

            bindsym Mod1+Shift+minus move scratchpad
            bindsym Mod1+minus scratchpad show

            bindsym Mod1+h focus left
            bindsym Mod1+j focus down
            bindsym Mod1+k focus up
            bindsym Mod1+l focus right

            bindsym Mod1+Shift+h move left
            bindsym Mod1+Shift+j move down
            bindsym Mod1+Shift+k move up
            bindsym Mod1+Shift+l move right

            bindsym Mod1+Return exec ${alacritty}
            bindsym Mod1+Shift+Return exec ${final.custom.private}/bin/private
            bindsym Mod1+Escape exec ${final.marcus.logout}/bin/logout
            bindsym Mod1+d exec ${final.marcus.rofi}/bin/rofi -show drun -i -drun-display-format {name} -theme-str 'entry { placeholder: "Launch"; }' 
            bindsym Mod1+Shift+e exec ${prev.custom.sway}/bin/swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'

            bindsym Mod1+Shift+c reload
            bindsym Mod1+Shift+q kill

            bindsym Mod1+Shift+space floating toggle

            bindsym Mod1+a focus parent
            bindsym Mod1+space focus mode_toggle

            bindsym Mod1+v splitv
            bindsym Mod1+b splith

            bindsym Mod1+e layout toggle split
            bindsym Mod1+f fullscreen toggle

            bindsym Mod1+r mode resize

            bindsym Mod1+s layout stacking
            bindsym Mod1+w layout tabbed

            bindsym Mod4+B exec ${final.brave}/bin/brave
            bindsym Mod4+D exec "${final.marcus.alacritty}/bin/alacritty --working-directory ~/.dotfiles --command vim .
            bindsym Print exec "${final.libnotify}/bin/notify-send --appname screenshot --urgency low --timeout 500 Screenshot; ${pkgs.sway-contrib.grimshot}/bin/grimshot save output"

            bindsym XF86AudioLowerVolume exec ${final.custom.volume}/bin/volume down
            bindsym XF86AudioMute exec ${final.custom.volume}/bin/volume toggle-mute
            bindsym XF86AudioRaiseVolume exec ${final.custom.volume}/bin/volume up
            bindsym XF86MonBrightnessDown exec ${final.custom.brightness}/bin/brightness down
            bindsym XF86MonBrightnessUp exec ${final.custom.brightness}/bin/brightness up

            input "*" {
              natural_scroll enabled
              repeat_delay 300
              tap enabled
              xkb_layout gb
            }

            output "*" {
              background ~/Downloads/wallpaper-inkwater.jpg fill
            }

            mode "resize" {
              bindsym Down resize grow height 10 px
              bindsym Escape mode default
              bindsym Left resize shrink width 10 px
              bindsym Return mode default
              bindsym Right resize grow width 10 px
              bindsym Up resize shrink height 10 px
              bindsym h resize shrink width 10 px
              bindsym j resize grow height 10 px
              bindsym k resize shrink height 10 px
              bindsym l resize grow width 10 px
            }

            gaps inner 10

            bar {
              swaybar_command waybar
              mode hide
              hidden_state hide
              modifier Mod1
            }
            
            exec "${final.dbus}/bin/dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE; systemctl --user start sway-session.target"
          '';
        };

        networking = prev.custom.networking.override {
          rofi = final.marcus.rofi;
        };

        logout = prev.custom.logout.override {
          rofi = final.marcus.rofi;
        };

        git = prev.custom.git.override {
          overrideConfig = ''
            [core]
              editor = vim
              pager = ${pkgs.delta}/bin/delta

            [credential "https://github.com"]
              helper = gh auth git-credential

            [delta]
              light = true
              navigate = true

            [diff]
              colorMoved = default

            [merge]
              conflictstyle = diff3

            [interactive]
              diffFilter = ${pkgs.delta}/bin/delta --color-only

            [user]
              name = "Marcus Whybrow"
              email = "marcus@whybrow.uk"
          '';
        };
      };
    })
  ];

  environment.systemPackages = with pkgs; [ light ];
  services.udev.packages = with pkgs; [ light ];

  users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = with pkgs; [
      htop lsof # htop requires lsof when you press `l` on a processF
      # TODO wrap htop with lsof in path 

      brave
      vimb
      discord
      obsidian

      plex-media-player

      ranger

      marcus.sway
      marcus.fish
      marcus.alacritty
      marcus.neovim
      marcus.waybar
      marcus.rofi
      marcus.dunst
      marcus.logout
      marcus.networking
      marcus.git gh

      custom.private
    ];

  };
}
