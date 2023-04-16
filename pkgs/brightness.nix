{
  pkgs,

  step ? 5,
}: pkgs.writeScriptBin "brightness" (let
  light = "${pkgs.light}/bin/light";
in ''
  delta=$(case $(${light} -G) in
    0.00) echo 1;;
    1.00) echo ${toString (step - 1)};;
    *)    echo ${toString step};;
  esac)

  case $1 in
    up)   ${light} -A $delta;;
    down) ${light} -U $delta;;
  esac

  brightness=$(${light} -G | cut --delimiter '.' --fields 1)

  ${pkgs.libnotify}/bin/notify-send \
    --app-name changeBrightness \
    --urgency low \
    --expire-time 2000 \
    --hint string:x-dunst-stack-tag:brightness \
    --hint int:value:$brightness \
    "Brightness $brightness%"

  ${light} -G
'')
