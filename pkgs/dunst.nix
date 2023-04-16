{
  pkgs,
  lib,
  makeWrapper,

  extraConfig ? {},
}: pkgs.runCommand "dunst" {
  nativeBuildInputs = [ makeWrapper ];
} (let
  inherit (lib) recursiveUpdate;

  toDunstIni = lib.generators.toINI {
    mkKeyValue = key: value: let
      value' = if builtins.isBool value then (if value then "true" else "false")
        else if builtins.isString value then ''"${value}"''
        else toString value;
    in "    ${key} = ${value'}";
  };

  baseConfig = {
    global = {
      origin = "top-right";
      offset = "60x40";
      frame_width = 4;
      frame_color = "#000000";
      font = "Noto Sans 10";
      markup = "full";
      transparency = 0;

      padding = 20;
      horizontal_padding = 20;

      line_height = 0;

      separator_height = 1;
      separator_color = "#000000";

      progress_bar_height = 30;
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

  config = pkgs.writeText "dunstrc" (toDunstIni (recursiveUpdate baseConfig extraConfig));
in ''
  mkdir -p $out/bin
  ln -s ${pkgs.dunst}/bin/* $out/bin

  rm $out/bin/dunst
  makeWrapper ${pkgs.dunst}/bin/dunst $out/bin/dunst \
    --add-flags "-config ${config}"


  mkdir -p $out/lib/systemd/user
  tee $out/lib/systemd/user/dunst.service << EOF
  [Unit]
  Description=Dunst notification daemon
  Documentation=man:dunst(1)
  PartOf=graphical-session.target

  [Service]
  Type=dbus
  BusName=org.freedesktop.Notifications
  ExecStart=$out/bin/dunst
  EOF


  mkdir -p $out/share/dbus-1/services
  tee $out/share/dbus-1/services/org.knopwob.dunst.service << EOF
  [D-BUS Service]
  Name=org.freedesktop.Notifications
  Exec=$out/bin/dunst
  SystemdService=dunst.service
  EOF


  mkdir -p $out/share/systemd/user
  ln -s $out/lib/systemd/user/dunst.service $out/share/systemd/user/dunst.service
'')
