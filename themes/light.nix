{ user, config, lib, pkgs, ... }: let
  inherit (lib) mkIf;
  inherit (builtins) mapAttrs removeAttrs readFile;
  inherit (lib.attrsets) mapAttrsToList zipAttrs;
  inherit (import ../utils { inherit lib; }) mapAttrsToListAndMerge merge;
in {

  programs.alacritty.settings.colors = merge [
    {
      primary = {
        background = "0xffffff";
        foreground = "0x2a2b33";
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
    output."*".background = "#FFFFFF solid_color";
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
        childBorder = "#ffffff";
      };
    };
  };

  programs.waybar.style = ''
    #waybar { background: white; color: #222; }
    .warning                   { color: orange; }
    .critical                  { color: red; }
    #workspaces button         { color: #222; }
    #workspaces button:hover   { color: black; }
    #workspaces button.focused { color: black; }
    #workspaces button.urgent  { color: #C9545D; }
  '';

  # Modified from https://github.com/anstellaire/photon-rofi-themes
  programs.rofi = {
    font = "Droid Sans Mono 10";
    theme = "mw-light";
  };
  xdg.dataFile."rofi/themes/mw-light.rasi".text = ''
    * {
        bg:           #ffffff;
        bg-border:    #000000;
        fg:           #333333;
        accent-bg:    #330000;
        accent-fg:    #ffffff;

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
}
