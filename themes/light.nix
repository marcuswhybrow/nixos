{ user, config, lib, pkgs, ... }: let
  inherit (lib) mkIf;
  inherit (builtins) mapAttrs removeAttrs readFile;
  inherit (lib.attrsets) mapAttrsToList zipAttrs;
  inherit (import ../utils { inherit lib; }) mapAttrsToListAndMerge merge;

  colors = {
    background = "ffffff";
    foreground = "000000";
    accent.background = "000000";
    accent.foreground = "ffffff";
    warning = "ffff00";
    critical = "ff0000";
  };
in {

  programs.alacritty.settings.colors = merge [
    {
      primary = {
        background = "0x${colors.background}";
        foreground = "0x${colors.foreground}";
      };
      normal.white = "0xbbbbbb";
      bright.white = "0xffffff";
    }
    (
      mapAttrsToListAndMerge (name: value: {
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
    output."*".background = "#${colors.background} solid_color";
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
        childBorder = "#${colors.background}";
      };
    };
  };

  programs.waybar.style = ''
    * {
      border: none;
      border-radius: 0;
      min-height: 0;
      margin: 0;
      padding: 0; }
    #waybar {
      background: #${colors.background};
      color: #${colors.foreground};
      font-family: monospace;
      font-size: 10px; }
    .warning { color: #${colors.warning}; }
    .critical { color: #${colors.critical}; }

    #network, #cpu, #memory, #temperature,
    #disk, #pulseaudio, #battery, #clock,
    #custom-logout, #workspaces, #tray,
    #mode { padding-top: 5px; }

    #tray        { padding-right: 10px; }
    #network     { padding-right: 10px; }
    #cpu         { padding-right: 3px; }
    #memory      { padding-right: 3px; }
    #temperature { padding-right: 10px; }
    #disk        { padding-right: 3px; }
    #pulseaudio  { padding-right: 3px; }
    #battery     { padding-right: 10px; }

    #clock.year                                        { padding-left: 10px }
    #clock.year, #clock.month, #clock.day, #clock.hour { padding-right: 3px }
    #clock.minute                                      { padding-right: 10px }

    #custom-logout { padding-right: 15px; }
    #window        {}

    #workspaces button {
      border-top: 2px solid transparent;
      color: #222222; }
    #workspaces button:hover {
      background: transparent;
      border-top: 2px solid transparent;
      color: #${colors.foreground};
      font-weight: bold; }
    #workspaces button.focused {
      color: #${colors.foreground};
      font-weight: bold; }
    #workspaces button.urgent { color: #${colors.warning}; }
    #mode { padding-left: 10px; }
  '';

  # Modified from https://github.com/anstellaire/photon-rofi-themes
  programs.rofi = {
    font = "Droid Sans Mono 10";
    theme = "mw-light";
  };
  xdg.dataFile."rofi/themes/mw-light.rasi".text = ''
    * {
        bg:           #${colors.background};
        bg-border:    #${colors.foreground};
        fg:           #333333;
        accent-bg:    #${colors.accent.background};
        accent-fg:    #${colors.accent.foreground};

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
  '';

  # wlogout is not in home-manager 22.11 but it is in master. I looked at the code:
  # https://github.com/nix-community/home-manager/blob/765e4007b6f9f111469a25d1df6540e8e0ca73a6/modules/programs/wlogout.nix#L144
  # I infered I could style it by creating layout and style.css

  # TODO Only set visual parts here (label, text)
  # and configure the rest in a module
  xdg.configFile."wlogout/layout".text = ''
    {
      "label" : "lock",
      "action" : "swaylock",
      "text" : "🔒 Lock",
      "keybind" : "l"
    }
    {
      "label" : "shutdown",
      "action" : "systemctl poweroff",
      "text" : "🔌 Shutdown",
      "keybind" : "s"
    }
    {
      "label" : "hibernate",
      "action" : "systemctl hibernate",
      "text" : "🧸 Hibernate",
      "keybind" : "h"
    }
    {
      "label" : "suspend",
      "action" : "systemctl suspend",
      "text" : "🔌 Suspend",
      "keybind" : "u"
    }
    {
      "label" : "logout",
      "action" : "loginctl terminate-user $USER",
      "text" : "🪵 Logout",
      "keybind" : "e"
    }
    {
      "label" : "reboot",
      "action" : "systemctl reboot",
      "text" : "🔌 Reboot",
      "keybind" : "r"
    }
  '';
  xdg.configFile."wlogout/style.css".text = ''
    * {
      background-image: none;
    }
    window {
      background-color: #${colors.background};
    }
    button {
      color: #${colors.background};
      background-color: #${colors.foreground};

      border-style: solid;
      border-width: 2px;
      border-color: #eeeeee;

      font-size: 30;
    }

    button:focus, button:active, button:hover {
      background-color: #${colors.accent.background};
      color: #${colors.accent.foreground};
      outline-style: none;
    }


    #reboot { }
  '';
}
