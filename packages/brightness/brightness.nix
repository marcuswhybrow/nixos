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

      source $config/init

      step=$(case $(${light} -G) in
        0.00) echo 1;;
        1.00) echo $(($step-1));;
        *) echo $step;;
      esac)

      brightness=$(${light} -G)

      case $1 in
        up)
          ${light} -A $step
          $config/on-change $(${light} -G)
          ;;
        down)
          ${light} -U $step
          $config/on-change $(${light} -G)
          ;;
      esac

      ${light} -G
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out
  '';
}
