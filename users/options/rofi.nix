{ config, pkgs, lib, types, ... }: let
  cfg = config.programs.rofi;
in {
  options.programs.rofi = {
    lightTheme = lib.mkEnableOption "Whether to enable a light theme";
  };

  config = lib.mkIf cfg.lightTheme {
    # Modified from https://github.com/anstellaire/photon-rofi-themes
    # See https://man.archlinux.org/man/rofi-theme.5
    programs.rofi = {
      font = "FiraCode Nerd Font";
      theme = "mw-light";
    };

    xdg.dataFile."rofi/themes/mw-light.rasi".text = ''
      * {
          bg:           #ffffff;
          bg-border:    #000000;
          fg:           #333333;
          accent-bg:    #000000;
          accent-fg:    #ffffff;

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

  };
}
