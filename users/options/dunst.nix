{ config, pkgs, lib, types, ... }: let
  cfg = config.services.dunst;
in {
  options.services.dunst = {
    lightTheme = lib.mkEnableOption "Whether to enable a light theme";
    frame.width = lib.mkOption { type = types.int; default = 4; };
    frame.color = lib.mkOption { type = types.str; default = "#000000"; };
    padding = lib.mkOption { type = types.int; default = 20; };
    background = lib.mkOption { type = types.str; default = "#ffffff"; };
    foreground = lib.mkOption { type = types.str; default = "#000000"; };
  };

  config = lib.mkIf cfg.lightTheme {
    # https://gitlab.manjaro.org/profiles-and-settings/manjaro-theme-settings/-/blob/master/skel/.config/dunst/dunstrc
    # See man 5 dunst
    xdg.configFile."dunst/dunstrc".text = ''
      [global]
        origin = top-right
        offset = 60x40
        frame_width = "${toString cfg.frame.width}"
        frame_color = "${cfg.frame.color}"
        font = Noto Sans 10
        markup = full
        geometry = 50x4-100+100
        transparency = 0

        padding = ${toString cfg.padding}
        horizontal_padding = ${toString cfg.padding}

        line_height = 0

        separator_height = 1
        separator_color = "#000000"

        dmenu = "${pkgs.rofi}/bin/rofi -show dmenu -p Notification"

        progress_bar_height = 20
        progress_bar_frame_width = 2

        # distance between notifications
        gap_size = 10

        corner_radius = 4

        background = "${cfg.background}"
        foreground = "${cfg.foreground}"


      [urgency_low]
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
