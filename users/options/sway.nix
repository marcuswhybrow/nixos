{ config, pkgs, lib, types, ... }: let
  cfg = config.wayland.windowManager.sway;
in {
  options.wayland.windowManager.sway = {
    lightTheme = lib.mkEnableOption "Whether to enable a light color theme";
  };

  config.wayland.windowManager.sway.config = lib.mkIf cfg.lightTheme {
    output."*".background = lib.mkDefault ''#ffffff solid_color'';
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
}
