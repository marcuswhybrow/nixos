{ config, pkgs, lib, types, helpers, ... }: let
  cfg = config.themes.light;
in {
  options.themes.light = {
    enable = lib.mkEnableOption "Whether to enable the light theme for GUI applications";
    background = lib.mkOption { type = lib.types.str; default = "ffffff"; };
    foreground = lib.mkOption { type = lib.types.str; default = "000000"; };
    accent.background = lib.mkOption { type = lib.types.str; default = "000000"; };
    accent.foreground = lib.mkOption { type = lib.types.str; default = "ffffff"; };
    warning = lib.mkOption { type = lib.types.str; default = "ff8800"; };
    critical = lib.mkOption { type = lib.types.str; default = "ff0000"; };
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty.settings.colors = helpers.attrs.merge [
      {
        primary = {
          background = "0x${cfg.background}";
          foreground = "0x${cfg.foreground}";
        };
        normal.white = "0xbbbbbb";
        bright.white = "0xffffff";
      }
      (
        helpers.attrs.mapAttrsToListAndMerge (name: value: {
          normal.${name} = value;
          bright.${name} = value;
        }) {
          black = "0x000000";
          red = "0xde3d35";
          green = "0x3e953a";
          yellow = "0xd2b67b";
          blue = "0x2f5af3";
          magenta = "0xa00095";
          cyan = "0x3e953a";
        }
      )
    ];

    programs.git.delta.options.light = true;

    programs.neovim = {
      plugins = [
        (pkgs.vimUtils.buildVimPluginFrom2Nix rec {
          pname = "github-nvim-theme";
          version = "0.0.7";
          src = pkgs.fetchFromGitHub {
            owner = "projekt0n";
            repo = "github-nvim-theme";
            rev = "refs/tags/v${version}";
            sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
          };
        })
      ];
      extraConfig = ''
        colorscheme github_light
      '';
    };

    wayland.windowManager.sway.config = {
      output."*".background = lib.mkDefault ''#${cfg.background} solid_color'';
      colors = {
        focused = {
          border = "#ff0000";
          background = "#ff0000";
          text = "#000000";
          indicator = "#ff0000";

          # The border of the app with input focus
          childBorder = "#666666";
        };
        focusedInactive = {
          border = "#ffffff";
          background = "#ffffff";
          text = "#000000";
          indicator = "#0000ff";
          # The border of the app in an inactive group that will
          # be selected first
          childBorder = "#eeeeee"; 
        };
        unfocused = {
          border = "#ffffff";
          background = "#ffffff";
          text = "#000000";
          indicator = "#00ff00";

          # The border of all other apps
          childBorder = "#${cfg.background}";
        };
      };
    };

    # Modified from https://github.com/anstellaire/photon-rofi-themes
    # See https://man.archlinux.org/man/rofi-theme.5
    programs.rofi = {
      font = "Droid Sans Mono 10";
      theme = "mw-light";
    };
    xdg.dataFile."rofi/themes/mw-light.rasi".text = ''
      * {
          bg:           #${cfg.background};
          bg-border:    #${cfg.foreground};
          fg:           #333333;
          accent-bg:    #${cfg.accent.background};
          accent-fg:    #${cfg.accent.foreground};

          secondary-fg: #888888;

          spacing:          10;

          background-color: @bg;
      }

      window {
          width:            40%;
          border:           2;
          padding:          5;
          background-color: @bg;
          border-color:     @bg-border;
      }

      inputbar {
          spacing:    0px;
          padding:    5px 5px 0px 5px;
          text-color: @fg;
          children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
      }

      prompt {
          spacing:    0;
          text-color: @fg;
      }

      textbox-prompt-colon {
          expand:     false;
          str:        ":";
          margin:     0px 0.3em 0em 0em ;
          text-color: @fg;
      }

      entry {
          spacing:    5px;
          text-color: @fg;
      }

      listview {
          fixed-height: 0;
          spacing:      0px;
          scrollbar:    false;
          lines:        20;
      }

      element {
          border:  0;
          padding: 5px 5px 5px 5px;
          background-color: @bg;
          text-color:       @fg;
      }

      element.selected {
          background-color: @accent-bg;
          text-color:       @accent-fg;
      }

      element-text {
          background-color: inherit;
          text-color:       inherit;
      }

      message {
          padding: 0 5px;
          text-color: @secondary-fg;
      }

    '';

    # https://gitlab.manjaro.org/profiles-and-settings/manjaro-theme-settings/-/blob/master/skel/.config/dunst/dunstrc
    # See man 5 dunst
    xdg.configFile."dunst/dunstrc".text = ''
      [global]
        origin = top-right
        offset = 60x40
        frame_width = 2
        frame_color = "#000000"
        font = Noto Sans 10
        markup = full
        geometry = 50x4-100+100
        transparency = 0
        padding = 10
        horizontal_padding = 10
        line_height = 0

        separator_height = 1
        separator_color = "#000000"

        # TODO Move out of theme
        dmenu = "${pkgs.rofi}/bin/rofi -show dmenu -p Notification"

        progress_bar_height = 20
        progress_bar_from_wdith = 1

        # distance between notifications
        gap_size = 10

        corner_radius = 0

      [urgency_low]
        background = "#ffffff"
        foreground = "#888888"
        frame_color = "#888888";
        timeout = 10

      [urgency_normal]
        background = "#ffffff"
        foreground = "#000000"
        timeout = 10

      [urgency_critical]
        background = "#ffffff"
        foreground = "#000000"
        frame_color = "#ff0000"
        timeout = 0

      [volume]
        appname = "changeVolume"
        urgency = low
        timeout = 2000
      [brightness]
        appname = "changeBrightness"
        urgency = low
        timeout = 2000
    '';
  };
}

