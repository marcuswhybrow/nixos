{
  pkgs,
}: pkgs.writeScriptBin "alarm" ''
  sleep $*

  ${pkgs.libnotify}/bin/notify-send \
    --app-name alarm \
    --urgency critical \
    --expire-time 3600000 \
    "Alarm $*"
''
