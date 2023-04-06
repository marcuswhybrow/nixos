{ config, pkgs, lib, types, ... }: let
  cfg = config.services.dunst;
in {
  options.services.dunst = {
    lightTheme = lib.mkEnableOption "Whether to enable a light theme";
  };

  config = lib.mkIf cfg.lightTheme {
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
