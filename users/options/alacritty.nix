{ config, pkgs, lib, types, helpers, ... }: let
  cfg = config.programs.alacritty;
in {
  options.programs.alacritty = {
    lightTheme = lib.mkEnableOption "Whether to enable a light color theme";
    firaCodeNerdFont = lib.mkEnableOption "Whether set Alacritty's font to FiraCode Nerd Font";
  };

  config.programs.alacritty.settings.colors = lib.mkIf cfg.lightTheme {
    primary = {
      background = lib.mkDefault "0xffffff";
      foreground = lib.mkDefault "0x000000";
    };

    normal = {
      white = "0xbbbbbb";
      black = "0x000000";
      red = "0xde3d35";
      green = "0x3e953a";
      yellow = "0xd2b67b";
      blue = "0x2f5af3";
      magenta = "0xa00095";
      cyan = "0x3e953a";
    };

    bright = {
      white = "0xffffff";
      black = "0x000000";
      red = "0xde3d35";
      green = "0x3e953a";
      yellow = "0xd2b67b";
      blue = "0x2f5af3";
      magenta = "0xa00095";
      cyan = "0x3e953a";
    };
  };

  config.programs.alacritty.settings.font = lib.mkIf cfg.firaCodeNerdFont (let
    fontFamily = "FiraCode Nerd Font";
  in {
    normal.family = fontFamily;
    normal.style = "Regular";

    bold.family = fontFamily;
    bold.style = "Bold";

    italic.family = fontFamily;
    italic.style = "Light";
  });
}
