{
  pkgs,
  lib,
  makeWrapper,

  extraConfig ? {},
}: pkgs.runCommand "dunst" {
  nativeBuildInputs = [ makeWrapper ];
} (let
  inherit (lib) recursiveUpdate;
  inherit (lib.generators) toINI;

  baseConfig = {
    global = {
      origin = "top-right";
      offset = "60x40";
      frame_width = 4;
      frame_color = "#000000";
      font = "Noto Sans 10";
      markup = "full";
      geometry = "50x4-100+100";
      transparency = 0;

      padding = 20;
      horizontal_padding = 20;

      line_height = 0;

      separator_height = 1;
      separator_color = "#000000";

      progress_bar_height = 3330;
      progress_bar_frame_width = 3; 

      # distance between notifications
      gap_size = 10;

      corner_radius = 4;

      background = "#ffffff";
      foreground = "#000000";
      highlight = "#000000";
    };

    urgency_low = {
      timeout = 10;
    };

    urgency_normal = {
      background = "#ffffff";
      foreground = "#000000";
      timeout = 10;
    };

    urgency_critical = {
      background = "#ffffff";
      foreground = "#000000";
      frame_color = "#ff0000";
      timeout = 0;
    };

    volume = {
      appname = "changeVolume";
      urgency = "low";
      timeout = 2000;
    };

    brightness = {
      appname = "changeBrightness";
      urgency = "low";
      timeout = 2000;
    };
  };

  config = pkgs.writeText "config" (toINI {} (recursiveUpdate baseConfig extraConfig));
in ''
  mkdir $out
  ln -s ${pkgs.dunst}/* $out
  rm $out/bin
  mkdir $out/bin
  ln -s ${pkgs.dunst}/bin/* $out/bin
  rm $out/bin/dunst
  makeWrapper ${pkgs.dunst}/bin/dunst $out/bin/dunst \
    --set XDG_CONFIG_DIRS $out/config

  mkdir -p $out/config/dunst
  ln -s ${config} $out/config/dunst/dunstrc
'')
