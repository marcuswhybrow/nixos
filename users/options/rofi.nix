{ config, pkgs, lib, types, ... }: let
  cfg = config.programs.rofi;
in {
  options.programs.rofi = {
    lightTheme = lib.mkEnableOption "Whether to enable a light theme";
    border.width = lib.mkOption { type = types.int; default = 4; };
    border.color = lib.mkOption { type = types.str; default = "#000000"; };
    element.selected.color = lib.mkOption { type = types.str; default = "#000000"; };
  };

  config = lib.mkIf cfg.lightTheme {
    # Modified from https://github.com/anstellaire/photon-rofi-themes
    # See https://man.archlinux.org/man/rofi-theme.5
    programs.rofi.theme = "mw-light";

    # https://github.com/newmanls/rofi-themes-collection/blob/master/themes/nord-oneline.rasi
    # https://github.com/davatorium/rofi/blob/next/doc/rofi-theme.5.markdown
    # This is not CSS
    xdg.dataFile."rofi/themes/mw-light.rasi".text = ''
      * {
        font: "FiraCode-Nerd-Font 12";
        spacing: 0px;
        margin: 0px;
        padding: 0px;
      }

      window {
        location: south;
        transparency: "real";
        background-color: transparent;
        width: 100%;
        margin: 100px; 
        spacing: 20px;
        children: [ horibox ];
      }

      horibox {
        orientation: horizontal;
        children: [ prompt, entry, listview ];
        background-color: #ffffff;
        border-color: ${cfg.border.color};
        border: ${toString cfg.border.width}px;
        border-radius: ${toString cfg.border.width}px;
        padding: 24px 20px;
        spacing: 10px;
      }

      prompt {
        text-color: #000000;
        spacing: 0px;
      }

      entry {
        placeholder: "Filter...";
        placeholder-color: #888888;
        expand: false;
        width: 10em;
      }

      listview {
        layout: horizontal;
        spacing: 10px;
      }

      element {
        text-color: #888888;
        spacing: 10px;
        padding: 0;
      }

      element-icon {
        size: 1em;
        background-color: transparent;
      }

      element-text {
        text-color: inherit;
        background-color: transparent;
      }

      element normal urgent {
        text-color: #ff0000;
      }

      element normal active {
        text-color: #0000ff;
      }

      element selected {
        text-color: ${cfg.element.selected.color};
      }

      element selected normal {
      }

      element selected urgent {
      }

      element selected active {
      }


    '';

  };
}
