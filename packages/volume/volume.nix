{
  stdenv,
  pkgs,
}: stdenv.mkDerivation {
  pname = "volume";
  version = "unstable";
  src = ./.;
  installPhase = let
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    script = pkgs.writeShellScriptBin "volume" ''
      config=''${XDG_CONFIG_HOME:-$HOME/.config}/volume

      [[ -f $config/init ]] && source $config/init

      step=''${step:-5}

      muteArgs=$([[ $unmuteOnChange == true ]] && echo "--unmute")

      delta=$(case $(${pamixer} --get-volume) in
        0) echo 1;;
        1) echo $(($step-1));;
        *) echo $step;;
      esac)

      case $1 in
        up)          ${pamixer} $muteArgs --increase $delta;;
        down)        ${pamixer} $muteArgs --decrease $delta;;
        toggle-mute) ${pamixer} --toggle-mute;;
      esac

      [[ -f $config/on-change ]] \
        && source $config/on-change \
          $(${pamixer} --get-volume) \
          $(${pamixer} --get-mute)
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out
  '';
}
