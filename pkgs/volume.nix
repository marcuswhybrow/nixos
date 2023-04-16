{
  pkgs,

  step ? 5,
  unmuteOnChange ? true,
}: pkgs.writeScriptBin "volume" (let
  pamixer = "${pkgs.pamixer}/bin/pamixer";
  muteArgs = if unmuteOnChange then "--unmute" else "";
in ''
  delta=$(case $(${pamixer} --get-volume) in
    0) echo 1;;
    1) echo ${toString (step - 1)};;
    *) echo ${toString step};;
  esac)

  case $1 in
    up)          ${pamixer} ${muteArgs} --increase $delta;;
    down)        ${pamixer} ${muteArgs} --decrease $delta;;
    toggle-mute) ${pamixer} --toggle-mute;;
  esac

  isMuted=$(${pamixer} --get-mute)
  volume=$(${pamixer} --get-volume)

  ${pkgs.libnotify}/bin/notify-send \
    --app-name changeVolume \
    --urgency low \
    --expire-time 2000 \
    --icon audio-volume-$([[ $isMuted == true ]] && echo muted || echo high) \
    --hint string:x-dunst-stack-tag:volume \
    $([[ $isMuted == false ]] && echo "--hint int:value:$volume") \
    "$([[ $isMuted == false ]] && echo "Volume: $volume%" || echo "Volume Muted")"
'')
