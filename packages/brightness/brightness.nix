{
  stdenv,
  pkgs,
}: stdenv.mkDerivation {
  pname = "brightness";
  version = "unstable";
  src = ./.;
  installPhase = let
    light = "${pkgs.light}/bin/light";
    script = pkgs.writeShellScriptBin "brightness" ''
      config=''${XDG_CONFIG_HOME:-$HOME/.config}/brightness

      [[ -f $config/init ]] && source $config/init

      step=''${step:-5}

      delta=$(case $(${light} -G) in
        0.00) echo 1;;
        1.00) echo $(($step-1));;
        *)    echo $step;;
      esac)

      case $1 in
        up)   ${light} -A $delta;;
        down) ${light} -U $delta;;
      esac

      brightness=$(${light} -G | cut --delimiter '.' --fields 1)

      [[ -f $config/on-change ]] \
        && $config/on-change $brightness

      ${light} -G
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out
  '';
}
